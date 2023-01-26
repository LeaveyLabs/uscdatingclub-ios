//
//  TakeTheTestVC.swift
//  scdatingclub-ios
//
//  Created by Adam Novak on 2023/01/03.
//

import UIKit

class TakeTheTestVC: UIViewController, PageVCChild {

    //MARK: - Properties
    
    //Flags
    let ANIMATION_DURATION: Double = 4.0
    
    //UI
    @IBOutlet var arrowView: UIImageView!
    
    @IBOutlet var aboutButton: UIButton!
    @IBOutlet var accountButton: UIButton!
    @IBOutlet var takeTheTestButton: SimpleButton!
    
    var pageVCDelegate: PageVCDelegate!

    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> TakeTheTestVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Radar) as! TakeTheTestVC
        vc.pageVCDelegate = delegate
        return vc
    }

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupArrowView()
        setupButtons()
        pulse(pulseView: arrowView, repeating: true)
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        aboutButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressBackwardButton()
        }), for: .touchUpInside)
        accountButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
        
        takeTheTestButton.internalButton.addTarget(self, action: #selector(didTapTestButton), for: .touchUpInside)
    }
    
    //MARK: - Helpers
    
    func pulse(pulseView: UIView, repeating: Bool) {
        UIView.animate(withDuration: ANIMATION_DURATION, delay: 0, options: [.curveLinear, .allowUserInteraction, .autoreverse]) {
            pulseView.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    func setupArrowView() {
//        for circleView in circleViews {
//            view.addSubview(circleView)
//            circleView.translatesAutoresizingMaskIntoConstraints = false
//            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            circleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CIRCLE_WIDTH_RATIO, constant: -10).isActive = true
//            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor, multiplier: 1).isActive = true
//
//            circleView.backgroundColor = .clear
//            circleView.layer.borderWidth = 2
//            circleView.layer.borderColor = UIColor.white.cgColor
//        }
//
//        view.addSubview(centerCircleButton)
//        centerCircleButton.translatesAutoresizingMaskIntoConstraints = false
//        centerCircleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        centerCircleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        centerCircleButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: CIRCLE_WIDTH_RATIO).isActive = true
//        centerCircleButton.widthAnchor.constraint(equalTo: centerCircleButton.heightAnchor, multiplier: 1).isActive = true
//
//        centerCircleButton.backgroundColor = .white
//        centerCircleButton.addTarget(self, action: #selector(didTapCenterCircle), for: .touchUpInside)
//        centerCircleButton.addTarget(self, action: #selector(centerCircleTouchUpOutside), for: .touchUpOutside)
//        centerCircleButton.addTarget(self, action: #selector(centerCircleTouchDown), for: .touchDown)
    }
    
    //MARK: - Interaction
    
    @objc func didTapTestButton() {
        let nav = UINavigationController(rootViewController: TestTextVC.create(type: .welcome))
        present(nav, animated: true)
    }
    
}

