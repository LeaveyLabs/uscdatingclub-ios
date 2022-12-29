//
//  AboutVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class AboutVC: UIViewController, PageVCChild {
    
    @IBOutlet var radarButton: UIButton!
    var pageVCDelegate: PageVCDelegate!

    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> AboutVC {
        let aboutVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.About) as! AboutVC
        aboutVC.pageVCDelegate = delegate
        return aboutVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
    }

}
