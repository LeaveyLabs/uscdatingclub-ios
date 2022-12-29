//
//  RadarVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class RadarVC: UIViewController, PageVCChild {

    //MARK: - Properties
    
    //Flags
    var isCurrentlyVisible = false
    
    let PULSE_DURATION: Double = 4.0
    let CIRCLE_WIDTH_RATIO: Double = 0.2
    
    var centerCircleView = UIView()
    var firstCircleView = UIView()
    var secondCircleView = UIView()
    var circleViews: [UIView] {
        [firstCircleView, secondCircleView]
    }
    
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var activeButton: SimpleButton!
    
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
        startPulsing()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isCurrentlyVisible = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCurrentlyVisible = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleViews.forEach { circleView in
            circleView.becomeRound()
        }
        centerCircleView.becomeRound()
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        aboutButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressBackwardButton()
        }), for: .touchUpInside)
        accountButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
        
        activeButton.configure(title: "active", systemImage: "")
        activeButton.internalButton.addTarget(self, action: #selector(didTapActiveButton), for: .touchUpInside)
    }

    func startPulsing() {
        pulse(pulseView: firstCircleView, repeating: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + PULSE_DURATION / 2) {
            self.pulse(pulseView: self.secondCircleView, repeating: true)
        }
    }
    
    func pulse(pulseView: UIView, repeating: Bool) {
        if isCurrentlyVisible {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        UIView.animate(withDuration: PULSE_DURATION, delay: 0, options: [.curveLinear, .allowUserInteraction]) {
            pulseView.transform = CGAffineTransform(scaleX: 1 / self.CIRCLE_WIDTH_RATIO, y: 1 / self.CIRCLE_WIDTH_RATIO)
            pulseView.alpha = 0
            pulseView.layer.borderWidth = 0
        } completion: { _ in
            pulseView.transform = .identity
            pulseView.alpha = 1
            pulseView.layer.borderWidth = 2
            if repeating {
                self.pulse(pulseView: pulseView, repeating: true)
            }
        }
    }
    
    func setupCircleViews() {
        for circleView in circleViews {
            view.addSubview(circleView)
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            circleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CIRCLE_WIDTH_RATIO).isActive = true
            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 1).isActive = true
            
            circleView.backgroundColor = .clear
            circleView.layer.borderWidth = 2
            circleView.layer.borderColor = UIColor.white.cgColor
        }
        
        view.addSubview(centerCircleView)
        centerCircleView.translatesAutoresizingMaskIntoConstraints = false
        centerCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        centerCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerCircleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CIRCLE_WIDTH_RATIO).isActive = true
        centerCircleView.widthAnchor.constraint(equalTo: centerCircleView.heightAnchor, multiplier: 1).isActive = true
        
        centerCircleView.backgroundColor = .white
        centerCircleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCenterCircle)))
    }
    
    //MARK: - Interaction
    
    @objc func didTapActiveButton() {
        let vc = PermissionsVC.create()
        present(vc, animated: true)
    }
    
    @objc func didTapCenterCircle() {
        print("DID TAP CENTER")
        let newCircleView = UIView()
        view.addSubview(newCircleView)
        newCircleView.translatesAutoresizingMaskIntoConstraints = false
        newCircleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        newCircleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        newCircleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CIRCLE_WIDTH_RATIO).isActive = true
        newCircleView.widthAnchor.constraint(equalTo: newCircleView.heightAnchor, multiplier: 1).isActive = true
        newCircleView.backgroundColor = .clear
        newCircleView.layer.borderWidth = 2
        newCircleView.layer.borderColor = UIColor.white.cgColor
        newCircleView.roundCornersViaCornerRadius(radius: firstCircleView.bounds.width / 2)
        pulse(pulseView: newCircleView, repeating: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + PULSE_DURATION) {
            newCircleView.removeFromSuperview()
        }
    }
    
}

