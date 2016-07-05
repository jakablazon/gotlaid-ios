//
//  RootViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/5/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource {
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.storyboard!.instantiateViewControllerWithIdentifier("FriendsViewController"),
            self.storyboard!.instantiateViewControllerWithIdentifier("ButtonViewController"),
            self.storyboard!.instantiateViewControllerWithIdentifier("FeedViewController")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        dataSource = self
        
        let buttonViewController = orderedViewControllers[1]
        setViewControllers([buttonViewController], direction: .Forward, animated: true, completion: nil)
    }
    
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
}
