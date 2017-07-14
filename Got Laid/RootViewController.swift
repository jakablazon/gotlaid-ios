//
//  RootViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/5/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.storyboard!.instantiateViewController(withIdentifier: "FriendsViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "ButtonViewController"),
            self.storyboard!.instantiateViewController(withIdentifier: "FeedViewController")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        dataSource = self
        delegate = self
        
        let buttonViewController = orderedViewControllers[1]
        setViewControllers([buttonViewController], direction: .forward, animated: true, completion: nil)
        
        Auth.auth().addStateDidChangeListener {
            (auth, user) in
            
            if user == nil {
                if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                    self.present(loginViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Status Bar
    static let statusBarAnimation = UIStatusBarAnimation.fade
    
    override var childViewControllerForStatusBarHidden : UIViewController? {
        return viewControllers?.first
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = index - 1
        if previousIndex < 0 || previousIndex >= orderedViewControllers.count {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = index + 1
        if nextIndex < 0 || nextIndex >= orderedViewControllers.count {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    // MARK: - Page View Controller Delegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }) 
    }
}
