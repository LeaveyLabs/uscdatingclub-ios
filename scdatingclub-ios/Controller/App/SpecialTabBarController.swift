//
//  CustomTabBarController.swift
//  CustomTabBar
//
//  Created by Adam Novak on 2022-06-07.
//

import UIKit
import Foundation

enum Tabs: Int, CaseIterable {
    case feed, map, dms
}

class FadePushAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
                let toViewController = transitionContext.viewController(forKey: .to)
                else {
            return
        }

        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            toViewController.view.alpha = 1
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })

    }
}

class SpecialTabBarController: UITabBarController {
    
    var shouldAnimateTransition: Bool = false
    
    public func tabBarController(
            _ tabBarController: UITabBarController,
            animationControllerForTransitionFrom fromVC: UIViewController,
            to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
                defer {
                    shouldAnimateTransition = false
                }
        return shouldAnimateTransition ? FadePushAnimator() : nil
    }
    
//    var promptsTabBadgeCount: Int! {
//        didSet {
//            DispatchQueue.main.async { [self] in
//                tabBar.items![1].badgeValue = promptsTabBadgeCount == 0 ? nil : String(promptsTabBadgeCount)
//                repositionBadges() //necessary or else badge position is incorrect
//            }
//        }
//    }
    
//    var mistboxTabBadgeCount: Int! {
//        didSet {
//            DispatchQueue.main.async { [self] in
//                tabBar.items![Tabs.mistbox.rawValue].badgeValue = mistboxTabBadgeCount == 0 ? nil : String(mistboxTabBadgeCount)
//                repositionBadges() //necessary or else badge position is incorrect
//            }
//        }
//    }
    
    var dmTabBadgeCount: Int! {
        didSet {
            DispatchQueue.main.async { [self] in
                tabBar.items![Tabs.dms.rawValue].badgeValue = dmTabBadgeCount == 0 ? nil : String(dmTabBadgeCount)
                repositionBadges()
            }
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.items?.forEach({ item in
            item.badgeColor = .primaryColor
            item.setBadgeTextAttributes([NSAttributedString.Key.font: UIFont(name: Constants.Font.Medium, size: 12)!], for: .normal)
        })
        removeLineAndAddShadow()
        tabBar.applyLightMediumShadow()
        refreshBadgeCount()
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Setup
    
    func removeLineAndAddShadow() {
        let tabBarLineHidingView = UIView()
        tabBarLineHidingView.backgroundColor = .white
        tabBar.addSubview(tabBarLineHidingView)
        tabBar.sendSubviewToBack(tabBarLineHidingView)
        tabBarLineHidingView.frame = tabBar.bounds
        tabBarLineHidingView.frame.origin.y -= 1 //hides the tab bar line
        tabBarLineHidingView.frame.size.height += 50 //extends down beyond safe area
    }
    
    func repositionBadges() {
//        var tabIndex = 0
        for tab in tabBar.subviews {
            for badgeView in tab.subviews {
                 if NSStringFromClass(badgeView.classForCoder) == "_UIBadgeView" {
                     badgeView.layer.transform = CATransform3DIdentity
                     //shift the middle tab bar button differently
                     badgeView.layer.transform = CATransform3DMakeTranslation(-8.0, -1.0, 1.0)

//                     if tabIndex == 0 {
//                         badgeView.layer.transform = CATransform3DMakeTranslation(-8.0, -1.0, 1.0)
//                     } else {
//                         badgeView.layer.transform = CATransform3DMakeTranslation(-8.0, -1.0, 1.0)
//                     }
//                     tabIndex += 1
                  }
             }
         }
     }
}

// MARK: - UITabBarController Delegate

extension SpecialTabBarController: UITabBarControllerDelegate {
    
    func presentNewPostNavVC(animated: Bool = true) {
//        let newPostNav = storyboard!.instantiateViewController(withIdentifier: Constants.SBID.VC.NewPostNavigation)
//        newPostNav.modalPresentationStyle = .fullScreen
//        present(newPostNav, animated: animated, completion: nil)
    }
    
    override func tabBar(_ tabBar: UITabBar, didEndCustomizing items: [UITabBarItem], changed: Bool) {
        presentNewPostNavVC()
    }

}

//MARK: - Notifications

extension SpecialTabBarController {
    
//    func decrementMistboxBadgeCount() {
//        mistboxTabBadgeCount -= 1
//    }
    
    @MainActor
    func refreshBadgeCount() {
//        if MistboxManager.shared.hasUserActivatedMistbox {
//            mistboxTabBadgeCount = MistboxManager.shared.getMistboxMists().count + DeviceService.shared.unreadMentionsCount()
//        } else {
//            tabBar.items![Tabs.mistbox.rawValue].badgeValue = ""
//            repositionBadges() //necessary or else badge position is incorrect
//        }
        
//        dmTabBadgeCount = ConversationService.singleton.getUnreadConversations().count
        
//        tabBar.items![Tabs.prompts.rawValue].badgeValue = CollectibleManager.shared.hasUserEarnedACollectibleToday ? nil : "1"
    }
    
}
