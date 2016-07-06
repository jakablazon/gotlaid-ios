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
        return [self.storyboard!.instantiateViewControllerWithIdentifier("FriendsViewController"),
            self.storyboard!.instantiateViewControllerWithIdentifier("ButtonViewController"),
            self.storyboard!.instantiateViewControllerWithIdentifier("FeedViewController")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        dataSource = self
        delegate = self
        
        let buttonViewController = orderedViewControllers[1]
        setViewControllers([buttonViewController], direction: .Forward, animated: true, completion: nil)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener {
            (auth, user) in
            
            if user == nil {
                if let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") {
                    self.presentViewController(loginViewController, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Status Bar
    static let statusBarAnimation = UIStatusBarAnimation.Fade
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return viewControllers?.first
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = index - 1
        if previousIndex < 0 || previousIndex >= orderedViewControllers.count {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let index = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = index + 1
        if nextIndex < 0 || nextIndex >= orderedViewControllers.count {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    // MARK: - Page View Controller Delegate
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            return
        }
        
        UIView.animateWithDuration(0.2) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
