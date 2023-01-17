//
//  AuthStartPageVC.swift
//  uscdatingclub-ios
//
//  Created by Adam Novak on 2023/01/16.
//

import UIKit

class AuthStartPageVC: UIPageViewController {

    //MARK: - Properties
    
    var vcs: [UIViewController]!
    var pageControl: UIPageControl!
    var continueButton: SimpleButton!
    var currentIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentIndex
            if currentIndex == vcs.count-1 && continueButton.alpha==0 {
                UIView.animate(withDuration: 0.3) {
                    self.continueButton.alpha = 1
                }
            }
            if currentIndex != vcs.count-1 && continueButton.alpha>0 {
                UIView.animate(withDuration: 0.3) {
                    self.continueButton.alpha = 0
                }
            }
        }
    }
    
    
    //MARK: - Initialization
    
    class func create() -> AuthStartPageVC {
        let vc = UIStoryboard(name: Constants.SBID.SB.Auth, bundle: nil).instantiateViewController(withIdentifier: Constants.SBID.VC.AuthStartPage) as! AuthStartPageVC
        return vc
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageVC()
        setupPageControl()
        setupContinueButton()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundDidTapped)))
    }
    
    var authStartVC: AuthStartVC!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authStartVC.agreementTextView.isHidden = navigationController == nil
    }
    
    //MARK: - Setup
    
    func setupPageVC() {
        authStartVC = AuthStartVC.create()
        vcs = [authStartVC,
               ScreenDemoVC.create(type: .notif),
               ScreenDemoVC.create(type: .match)]
        
        self.dataSource = self
        self.delegate = self
        
        setViewControllers([vcs[0]], direction: .forward, animated: false)
    }
    
    func setupContinueButton() {
        continueButton = SimpleButton()
        view.addSubview(continueButton)
        continueButton.backgroundColor = .customWhite
        continueButton.configure(title: "join the club", systemImage: "")
        continueButton.internalButton.addTarget(self, action: #selector(continueButtonDidPressed), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: view.safeBottomAnchor, constant: -10).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        continueButton.alpha = 0
        continueButton.isHidden = navigationController == nil
    }
    
    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 110,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = vcs.count
        self.pageControl.currentPage = 0
        self.pageControl.alpha = 0.5
        self.pageControl.tintColor = .customWhite
        self.pageControl.pageIndicatorTintColor = .customWhite.withAlphaComponent(0.5)
        self.pageControl.currentPageIndicatorTintColor = .customWhite
        self.view.addSubview(pageControl)
    }
    
    //MARK: - Interaction
    
    @objc func backgroundDidTapped() {
        goToNextPage(animated: true) { completed in
            self.recalculateCurrentIndex()
        }
    }
    
    @objc func continueButtonDidPressed() {
        navigationController?.pushViewController(EnterNumberVC.create(), animated: true)
    }
    
    //MARK: - Helper
    
    func recalculateCurrentIndex() {
        currentIndex = vcs.firstIndex(of: viewControllers!.first!)!
    }
    
}

//MARK: - UIPageViewControllerDelegate

extension AuthStartPageVC: UIPageViewControllerDelegate, UIScrollViewDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            recalculateCurrentIndex()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        recalculateCurrentIndex()
    //        let offSet = scrollView.contentOffset.x
    //        let width = scrollView.frame.width
    //        let horizontalCenter = width / 2
    //        pageControl.currentPage = Int(offSet + horizontalCenter) / Int(width)
        
        //prevent going beyond edge
        if (currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) || (currentIndex == vcs.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
          scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
    
    //prevent going beyond edge, edge case
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (currentIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) || (currentIndex == vcs.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
          targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
      }
        
}

//MARK: = UIPageViewControllerDataSource

extension AuthStartPageVC: UIPageViewControllerDataSource {
    
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
