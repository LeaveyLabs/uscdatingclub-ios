//
//  RadarVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit
import FirebaseAnalytics
import Mixpanel

class RadarVC: UIViewController, PageVCChild {
    
    enum HomeState {
        case radar, arrow
    }

    //MARK: - Properties
    
    //Flags
    var isCurrentlyVisible = false
    var isPulsing = false
    var isLocationServicesEnabled: Bool = UserService.singleton.getIsMatchable() {
        didSet {
            Task {
                try await UserService.singleton.updateMatchableStatus(active: isLocationServicesEnabled)
                if isLocationServicesEnabled {
                    LocationManager.shared.startLocationServices()
                } else {
                    LocationManager.shared.stopLocationServices()
                }
            }
        }
    }
    
    var uiState: HomeState {
        return UserService.singleton.getSurveyResponses().isEmpty ? .arrow : .radar
    }
    
    static let PULSE_DURATION: Double = 4.0
    static let CIRCLE_WIDTH_RATIO: Double = 0.2
    
    var centerCircleButton = UIButton()
    var firstCircleView = UIView()
    var secondCircleView = UIView()
    var circleViews: [UIView] {
        [firstCircleView, secondCircleView]
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var arrowView: UIImageView!
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var primaryButton: SimpleButton!
    @IBOutlet var primaryButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var cupidButton: UIButton!
    
    var pageVCDelegate: PageVCDelegate!

    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> RadarVC {
        let radarVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Radar) as! RadarVC
        radarVC.pageVCDelegate = delegate
        return radarVC
    }

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCircleViews()
        setupButtons()
        titleLabel.font = AppFont.bold.size(20)
        setupPermissions()
        NotificationCenter.default.addObserver(self, selector: #selector(startPulsing), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func setupPermissions() {
        PermissionsManager.areAllNecessaryPermissionsGranted(closure: { enabled in
            if !enabled {
                DispatchQueue.main.async { [self] in
                    isLocationServicesEnabled = false
                    renderUI()
                }
            }
        })
        
        PermissionsManager.areAllPermissionsGranted { enabled in
            if !enabled && self.uiState == .radar {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.presentPermissionsScreen()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: .necessaryPermissionsWereRevoked, object: nil, queue: .main) { [self] notification in
            isLocationServicesEnabled = false
            renderUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLocationServicesEnabled = UserService.singleton.getIsMatchable()
        renderUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isCurrentlyVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCurrentlyVisible = false
        stopPulsing()
        firstCircleView.layer.removeAllAnimations()
        secondCircleView.layer.removeAllAnimations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleViews.forEach { circleView in
            circleView.becomeRound()
        }
        centerCircleButton.becomeRound()
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        cupidButton.isHidden = !UserService.singleton.isSuperuser()
        cupidButton.addAction(.init(handler: { [self] _ in
            cupidButtonPressed()
        }), for: .touchUpInside)
        
        aboutButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressBackwardButton()
        }), for: .touchUpInside)
        accountButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
        
        primaryButton.internalButton.addTarget(self, action: #selector(didTapActiveButton), for: .touchUpInside)
    }
    
    func renderUI() {
        switch uiState {
        case .arrow:
            (parent as? PageVC)?.scrollView?.isScrollEnabled = false
            aboutButton.isHidden = true
            accountButton.isHidden = true
            arrowView.isHidden = false
            centerCircleButton.isHidden = true
            circleViews.forEach { $0.isHidden = true }
            centerCircleButton.isHidden = true
            primaryButton.configure(title: "take the\ncompatibility test", systemImage: "testtube.2", imageSize: 22)
            primaryButton.internalButton.backgroundColor = .customWhite
            primaryButton.internalButton.setTitleColor(.customBlack, for: .normal)
            primaryButtonHeightConstraint.constant = 90
            pulseArrow()
        case .radar:
            (parent as? PageVC)?.scrollView?.isScrollEnabled = true
            aboutButton.isHidden = false
            accountButton.isHidden = false
            arrowView.isHidden = true
            centerCircleButton.isHidden = false
            circleViews.forEach { $0.isHidden = false }
            centerCircleButton.isHidden = false
            primaryButton.internalButton.setTitleColor(.customWhite, for: .normal)
            primaryButton.internalButton.imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
            primaryButtonHeightConstraint.constant = 60
            renderIsActive()
            if isLocationServicesEnabled {
                startPulsing(fromZero: false)
            }
        }
    }
    
    func renderIsActive() {
        if isLocationServicesEnabled {
            primaryButton.configure(title: "active", systemImage: "")
            primaryButton.internalButton.backgroundColor = .customGreen
            primaryButton.internalButton.setTitleColor(.black, for: .normal)
            //start pulsing is called elsewhere
        } else {
            primaryButton.configure(title: "inactive", systemImage: "")
            primaryButton.internalButton.backgroundColor = .customRed
            primaryButton.internalButton.setTitleColor(.white, for: .normal)
            stopPulsing()
        }
    }
    
    //MARK: - Pulsing
    
    func stopPulsing() {
        isPulsing = false
    }

    @objc func startPulsing(fromZero: Bool = false) {
        isPulsing = true
        firstCircleView.layer.removeAllAnimations()
        secondCircleView.layer.removeAllAnimations()
        if fromZero {
            pulse(startingPercent: 0, pulseView: firstCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
            DispatchQueue.main.asyncAfter(deadline: .now() + RadarVC.PULSE_DURATION / 2) { [weak self] in
                guard let self else { return }
                self.pulse(startingPercent: 0, pulseView: self.secondCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
            }
        } else {
            let percentCompleted = Double.random(in: 0.5...1)
            pulse(startingPercent: percentCompleted, pulseView: firstCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
            pulse(startingPercent: percentCompleted-0.5, pulseView: secondCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
        }
    }
    
    func pulse(startingPercent: Double, pulseView: UIView, repeating: Bool, duration: Double) {
        guard isPulsing else { return }
        if isCurrentlyVisible {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        pulseView.alpha = (1-startingPercent)
        pulseView.layer.borderWidth = 2 * (1-startingPercent)
        let startingTransform = 1 + RadarVC.PULSE_DURATION * startingPercent
        pulseView.transform = CGAffineTransform(scaleX: startingTransform,
                                                y: startingTransform)
        
        UIView.animate(withDuration: duration - (startingPercent*duration), delay: 0, options: [.curveLinear, .allowUserInteraction]) { [weak self] in
            guard self != nil else { return }
            pulseView.transform = CGAffineTransform(scaleX: 1 / RadarVC.CIRCLE_WIDTH_RATIO, y: 1 / RadarVC.CIRCLE_WIDTH_RATIO)
            pulseView.alpha = 0
            pulseView.layer.borderWidth = 0
        } completion: { [weak self] completed in
            guard let self else { return }
            pulseView.transform = .identity
            pulseView.alpha = 1
            pulseView.layer.borderWidth = 2
            if repeating && completed {
                self.pulse(startingPercent: 0, pulseView: pulseView, repeating: true, duration: duration)
            }
        }
    }
    
    func pulseArrow() {
        arrowView.transform = .identity //necessary to ensure the animation resumes after recreating VC
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveLinear, .allowUserInteraction, .autoreverse, .repeat]) {
            self.arrowView.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    func setupCircleViews() {
        for circleView in circleViews {
            view.addSubview(circleView)
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            circleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: RadarVC.CIRCLE_WIDTH_RATIO, constant: -10).isActive = true
            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 1).isActive = true
            
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 2
            circleView.layer.borderColor = UIColor.white.cgColor
        }
        
        view.addSubview(centerCircleButton)
        centerCircleButton.translatesAutoresizingMaskIntoConstraints = false
        centerCircleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerCircleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerCircleButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: RadarVC.CIRCLE_WIDTH_RATIO).isActive = true
        centerCircleButton.widthAnchor.constraint(equalTo: centerCircleButton.heightAnchor, multiplier: 1).isActive = true
        
        centerCircleButton.backgroundColor = .white
        centerCircleButton.addTarget(self, action: #selector(didTapCenterCircle), for: .touchUpInside)
        centerCircleButton.addTarget(self, action: #selector(centerCircleTouchUpOutside), for: .touchUpOutside)
        centerCircleButton.addTarget(self, action: #selector(centerCircleTouchDown), for: .touchDown)
    }
    
    //MARK: - Helpers
    
    func presentPermissionsScreen() {
        let permissionsVC = PermissionsVC.create()
        permissionsVC.modalPresentationStyle = .fullScreen
        present(permissionsVC, animated: true)
    }
    
    func animateANewCircle() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.centerCircleButton.transform = .identity
        }
        guard isLocationServicesEnabled else { return }
        let newCircleView = UIView()
        view.addSubview(newCircleView)
        newCircleView.translatesAutoresizingMaskIntoConstraints = false
        newCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newCircleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: RadarVC.CIRCLE_WIDTH_RATIO, constant: -10).isActive = true
        newCircleView.widthAnchor.constraint(equalTo: newCircleView.heightAnchor, multiplier: 1).isActive = true
        newCircleView.backgroundColor = .clear
        newCircleView.layer.borderWidth = 2
        newCircleView.layer.borderColor = UIColor.white.cgColor
        newCircleView.roundCornersViaCornerRadius(radius: firstCircleView.bounds.width / 2)
        pulse(startingPercent: 0, pulseView: newCircleView, repeating: false, duration: RadarVC.PULSE_DURATION)
        DispatchQueue.main.asyncAfter(deadline: .now() + RadarVC.PULSE_DURATION) {
            newCircleView.removeFromSuperview()
        }
    }
    
    func presentTest() {
        let nav = UINavigationController(rootViewController: TestTextVC.create(type: .welcome))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    //MARK: - Interaction
    
    @objc func didTapActiveButton() {
        switch uiState {
        case .radar:
            Mixpanel.mainInstance().track(event: isLocationServicesEnabled ? "BecomeInactive" : "BecomeActive")
            Analytics.logEvent(isLocationServicesEnabled ? "BecomeInactive" : "BecomeActive", parameters: nil)
            if isLocationServicesEnabled {
                isLocationServicesEnabled = false
                renderIsActive()
            } else {
                PermissionsManager.areAllPermissionsGranted { areAllGranted in
                    DispatchQueue.main.async { [self] in
                        if areAllGranted {
                            isLocationServicesEnabled = true
                            renderIsActive()
                            startPulsing(fromZero: true)
                        } else {
                            presentPermissionsScreen()
                        }
                    }
                }
            }
        case .arrow:
            presentTest()
        }
    }
    
    func cupidButtonPressed() {
        present(ForgeMatchVC.create(), animated: true)
    }
    
    @objc func centerCircleTouchDown() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.centerCircleButton.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }
    }
    
    @objc func centerCircleTouchUpOutside() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.centerCircleButton.transform = .identity
        }
    }
    
    @objc func didTapCenterCircle() {
        didTapActiveButton()
    }
    
}

