//
//  RadarVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class RadarVC: UIViewController, PageVCChild {

    //MARK: - Properties
    
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
        print(#function)
        setupCircleViews()
        startPulsing()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(#function)
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
    }

    func startPulsing() {
        firstCircleView.pulse(duration: PULSE_DURATION)
        DispatchQueue.main.asyncAfter(deadline: .now() + PULSE_DURATION / 2) {
            self.secondCircleView.pulse(duration: self.PULSE_DURATION)
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
    }
}

extension UIView {
    
    func pulse(duration: Double) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear, .allowUserInteraction]) {
            self.transform = CGAffineTransform(scaleX: 5, y: 5)
            self.alpha = 0
            self.layer.borderWidth = 0
        } completion: { _ in
            self.transform = .identity
            self.alpha = 1
            self.layer.borderWidth = 2
            self.pulse(duration: duration)
        }
    }
}
