//
//  PageViewController.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2022/12/28.
//

import UIKit

class PageVC: UIPageViewController {
    
    //MARK: - Properties
    
    var aboutXConstraint: NSLayoutConstraint!
    var radarXConstraint: NSLayoutConstraint!
    var accountXConstraint: NSLayoutConstraint!

    var currentIndex: Int = 1
    let vcs: [UIViewController] = [UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.About),
                                   UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Radar),
                                   UIStoryboard(name: Constants.SBID.SB.Main, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.Account)]

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
        
        let asdf = UIView()
        asdf.backgroundColor = .black
        view.addSubview(asdf)
        asdf.translatesAutoresizingMaskIntoConstraints = false
        asdf.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        asdf.topAnchor.constraint(equalTo: view.safeTopAnchor, constant: 0).isActive = true
        asdf.heightAnchor.constraint(equalToConstant: 55).isActive = true
        asdf.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        let radarHeader = UILabel()
        radarHeader.text = "usc dating club"
        radarHeader.textColor = .white
        asdf.addSubview(radarHeader)
        
        radarHeader.translatesAutoresizingMaskIntoConstraints = false
        radarHeader.centerYAnchor.constraint(equalTo: asdf.centerYAnchor).isActive = true
        radarXConstraint = radarHeader.centerXAnchor.constraint(equalTo: asdf.centerXAnchor)
        radarXConstraint.isActive = true
        
        let aboutHeader = UILabel()
        aboutHeader.text = "about"
        aboutHeader.textColor = .white
        asdf.addSubview(aboutHeader)
        
        aboutHeader.translatesAutoresizingMaskIntoConstraints = false
        aboutHeader.centerYAnchor.constraint(equalTo: asdf.centerYAnchor).isActive = true
        aboutXConstraint = aboutHeader.leadingAnchor.constraint(equalTo: asdf.leadingAnchor, constant: 20)
        aboutXConstraint.isActive = true
        
        let accountHeader = UILabel()
        accountHeader.text = "account"
        accountHeader.textColor = .white
        asdf.addSubview(accountHeader)
        
        accountHeader.translatesAutoresizingMaskIntoConstraints = false
        accountHeader.centerYAnchor.constraint(equalTo: asdf.centerYAnchor).isActive = true
        accountXConstraint = accountHeader.trailingAnchor.constraint(equalTo: asdf.trailingAnchor, constant: 20)
        accountXConstraint.isActive = true
    }
    
    func setupPageVC() {
        self.dataSource = self
        self.delegate = self
        for view in view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
        setViewControllers([vcs[currentIndex]], direction: .forward, animated: false)
    }
    
    func recalculateCurrentIndex() {
        currentIndex = vcs.firstIndex(of: viewControllers!.first!)!
    }
    
}

//MARK: - UIScrollViewDelegate

extension PageVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        scrollView.bounces = currentIndex != 0 && currentIndex != vcs.count-1 //disabling bounce can sometimes entirely disable page scrolling. not appropriate solution
        print(scrollView.contentOffset.x, scrollView.panGestureRecognizer.translation(in: view).x)
        
        radarXConstraint.constant = scrollView.panGestureRecognizer.translation(in: view).x / 3
        
        
        if (currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) || (currentIndex == vcs.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
              scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
            }
    }
    
    //edge case
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (currentIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) || (currentIndex == vcs.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
          targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
      }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        recalculateCurrentIndex()
    }
        
}

//MARK: - UIPageViewControllerDelegate

extension PageVC: UIPageViewControllerDelegate {
    
//    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
//        print("WILL TRANSITION")
//    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            recalculateCurrentIndex()
        }
    }
        
}

//MARK: = UIPageViewControllerDataSource

extension PageVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = vcs.firstIndex(of: viewController)!
        guard index > 0 else { return nil }
        return vcs[index-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = vcs.firstIndex(of: viewController)!
        guard index < vcs.count-1 else { return nil }
        return vcs[index+1]
    }
    
}
