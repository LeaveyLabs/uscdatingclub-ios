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
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var simpleButtonOne: SimpleButton!
    @IBOutlet weak var simpleButtonTwo: SimpleButton!
    @IBOutlet weak var simpleButtonThree: SimpleButton!
    @IBOutlet weak var simpleButtonFour: SimpleButton!
    @IBOutlet weak var simpleButtonFive: SimpleButton!
    @IBOutlet weak var simpleButtonSix: SimpleButton!


    //MARK: - Initialization
    
    class func create(delegate: PageVCDelegate) -> AboutVC {
        let aboutVC = UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.About) as! AboutVC
        aboutVC.pageVCDelegate = delegate
        return aboutVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        versionLabel.text = "\(Version.currentVersion)"
    }
    
    //MARK: - Setup
    
    func setupButtons() {
        radarButton.addAction(.init(handler: { [self] _ in
            pageVCDelegate.didPressForwardButton()
        }), for: .touchUpInside)
        
        simpleButtonOne.configure(title: "how it works", systemImage: "info.circle")
        simpleButtonOne.internalButton.addTarget(self, action: #selector(howItWorksButtonPressed), for: .touchUpInside)
        simpleButtonTwo.configure(title: "faq", systemImage: "questionmark.bubble")
        simpleButtonTwo.internalButton.addTarget(self, action: #selector(faqButtonPressed), for: .touchUpInside)
        simpleButtonThree.configure(title: "share", systemImage: "square.and.arrow.up")
        simpleButtonThree.internalButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
        simpleButtonFour.configure(title: "rate", systemImage: "star")
        simpleButtonFour.internalButton.addTarget(self, action: #selector(rateButtonPressed), for: .touchUpInside)
        simpleButtonFive.configure(title: "give feedback", systemImage: "message")
        simpleButtonFive.internalButton.addTarget(self, action: #selector(feedbackButtonPressed), for: .touchUpInside)
        simpleButtonSix.configure(title: "contact us", systemImage: "hand.wave")
        simpleButtonSix.internalButton.addTarget(self, action: #selector(contactButtonPressed), for: .touchUpInside)
    }
    
    //MARK: - Interaction
    
    @objc func howItWorksButtonPressed() {
        let howItWorksVC = HowItWorksVC.create()
        present(howItWorksVC, animated: true)
    }
    
    @objc func faqButtonPressed() {
        openURL(Constants.faqLink)
    }
    
    @objc func shareButtonPressed() {
        presentShareAppActivity()
    }
    
    @objc func rateButtonPressed() {
        AppStoreReviewManager.offerViewPromptUponUserRequest()
    }
    
    @objc func feedbackButtonPressed() {
        openURL(Constants.feedbackLink)
    }
    
    @objc func contactButtonPressed() {
        openMailtoURL(Constants.contactLink)
    }
    
    @IBAction func termsButtonDidPressed() {
        openURL(Constants.termsLink)
    }
    
    @IBAction func privacyButtonDidPressed() {
        openURL(Constants.privacyPageLink)
    }

}
