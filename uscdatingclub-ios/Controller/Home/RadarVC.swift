//
//  RadarVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

var temphasAnsweredQuestions = true

class RadarVC: UIViewController, PageVCChild {
    
    enum HomeState {
        case radar, arrow
    }

    //MARK: - Properties
    
    //Flags
    var isCurrentlyVisible = false
    var isLocationServicesEnabled: Bool = false
    var isPulsing = false
    
    var uiState: HomeState {
        return temphasAnsweredQuestions ? .radar : .arrow
//        UserService.singleton.hasAnsweredQuestions
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
    }
    
    func setupPermissions() {
        PermissionsManager.areAllPermissionsGranted(closure: { enabled in
            if !enabled {
                DispatchQueue.main.async { [self] in
                    isLocationServicesEnabled = false
                    renderIsActive()
                }
            }
        })
        
        NotificationCenter.default.addObserver(forName: .permissionsWereRevoked, object: nil, queue: .main) { [self] notification in
            isLocationServicesEnabled = false
            renderIsActive()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            arrowView.isHidden = true
            centerCircleButton.isHidden = false
            circleViews.forEach { $0.isHidden = false }
            centerCircleButton.isHidden = false
            primaryButton.internalButton.setTitleColor(.customWhite, for: .normal)
            primaryButton.internalButton.imageView?.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
            primaryButtonHeightConstraint.constant = 60
            renderIsActive()
        }
    }
    
    func renderIsActive() {
        if isLocationServicesEnabled {
            primaryButton.configure(title: "active", systemImage: "")
            primaryButton.internalButton.backgroundColor = .customGreen
            primaryButton.internalButton.setTitleColor(.black, for: .normal)
            
            //if already loaded?
            startPulsing()
            LocationManager.shared.startLocationServices()
        } else {
            primaryButton.configure(title: "inactive", systemImage: "")
            primaryButton.internalButton.backgroundColor = .customRed
            primaryButton.internalButton.setTitleColor(.white, for: .normal)
            
            stopPulsing()
            LocationManager.shared.stopLocationServices()
        }
    }
    
    //MARK: - Helpers
    
    func makeNavButtonsVisible(_ visible: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: []) { [self] in
            accountButton.alpha = visible ? 1 : 0
            aboutButton.alpha = visible ? 1 : 0
        }
    }
    
    func stopPulsing() {
        isPulsing = false
    }

    func startPulsing() {
        isPulsing = true
        firstCircleView.layer.removeAllAnimations()
        secondCircleView.layer.removeAllAnimations()
        pulse(pulseView: firstCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
        DispatchQueue.main.asyncAfter(deadline: .now() + RadarVC.PULSE_DURATION / 2) { [weak self] in
            guard let self else { return }
            self.pulse(pulseView: self.secondCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
        }
    }
    
//    func resumePulsing() {
//        firstCircleView.layer.removeAllAnimations()
//        secondCircleView.layer.removeAllAnimations()
//
//        firstCircleView.transform = CGAffineTransform(scaleX: 100, y: 100)
//        secondCircleView.transform = .identity
//
//        pulse(pulseView: firstCircleView, repeating: true, duration: RadarVC.PULSE_DURATION/2)
//        pulse(pulseView: secondCircleView, repeating: true, duration: RadarVC.PULSE_DURATION)
//    }
    
    func pulse(pulseView: UIView, repeating: Bool, duration: Double) {
        guard isPulsing else { return }
        if isCurrentlyVisible {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear, .allowUserInteraction]) { [weak self] in
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
                self.pulse(pulseView: pulseView, repeating: true, duration: duration)
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
    
    //MARK: - Interaction
    
    @objc func didTapActiveButton() {
        switch uiState {
        case .radar:
            if isLocationServicesEnabled {
                isLocationServicesEnabled = false
                renderIsActive()
                Task {
                    try await UserService.singleton.updateMatchableStatus(active:false)
                }
            } else {
                PermissionsManager.areAllPermissionsGranted { areAllGranted in
                    DispatchQueue.main.async { [self] in
                        if areAllGranted {
                            isLocationServicesEnabled = true
                            renderIsActive()
                            Task {
                                try await UserService.singleton.updateMatchableStatus(active:true)
                            }
                        } else {
                            let permissionsVC = PermissionsVC.create()
                            permissionsVC.modalPresentationStyle = .fullScreen
                            present(permissionsVC, animated: true)
                        }
                    }
                }
            }
        case .arrow:
            presentTest()
        }
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
        pulse(pulseView: newCircleView, repeating: false, duration: RadarVC.PULSE_DURATION)
        DispatchQueue.main.asyncAfter(deadline: .now() + RadarVC.PULSE_DURATION) {
            newCircleView.removeFromSuperview()
        }
    }
    
    //MARK: - Helpers
    
    func presentTest() {
        TestContext.reset()
        TestContext.isFirstTest = true
        let nav = UINavigationController(rootViewController: TestTextVC.create(type: .welcome))
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
}

