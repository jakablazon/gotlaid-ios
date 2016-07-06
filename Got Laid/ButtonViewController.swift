//
//  ViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/4/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class ButtonViewController: UIViewController, FacebookDataSelectedFriendsDelegate {
    @IBOutlet weak var laidButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var whooopLabel: UILabel!
    
    let animationTime = 0.3
    let delay = 3.0
    
    var numberOfFriends = FacebookData.sharedInstance.selectedFriends.count
    
    var initialState = true
    
    let databaseRefrence = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        laidButton.titleLabel?.textAlignment = .Center
        laidButton.layer.cornerRadius = 108
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(laidButtonCancel))
        view.addGestureRecognizer(tap)
        
        refreshLabel()
        
        FacebookData.sharedInstance.selectedFriendsDelegate = self
    }
    
    // MARK: - Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return RootViewController.statusBarAnimation
    }
    
    // MARK: - Logout
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch _ {}
        FBSDKLoginManager().logOut()
    }
    
    // MARK: - Laid Button
    func laidButtonCancel(sender: AnyObject) {
        if !initialState {
            initialState = true
            laidButton.setTitle("I JUST\nGOT LAID", forState: .Normal)
        }
    }
    
    @IBAction func laidButtonPressed(sender: AnyObject) {
        if initialState {
            laidButton.setTitle("YOU\nSURE?", forState: .Normal)
            initialState = false
        } else {
            pushToServer()
            
            displayWhooopLabel()
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideWhooopLabel()
            }
            
            self.infoLabel.text = "\(numberOfFriends) FRIENDS\nNOTIFIED"
            initialState = true
        }
    }
    
    // MARK: - Label Animations
    func displayWhooopLabel() {
        whooopLabel.alpha = 0.0
        whooopLabel.hidden = false
        UIView.animateWithDuration(animationTime,
                                   animations: {
                                    self.whooopLabel.alpha = 1.0
                                    self.laidButton.alpha = 0.0
                                   }, completion: {_ in
                                    self.laidButton.hidden = true
        })
    }
    
    func hideWhooopLabel() {
        laidButton.hidden = false
        laidButton.setTitle("I JUST\nGOT LAID", forState: .Normal)
        UIView.animateWithDuration(animationTime,
                                   animations: {
                                    self.whooopLabel.alpha = 0.0
                                    self.laidButton.alpha = 1.0
                                  }, completion: {_ in
                                    self.whooopLabel.hidden = true
        })
        
        self.infoLabel.text = "LET \(numberOfFriends) OF YOUR\nFRIENDS KNOW"
    }
    
    func refreshLabel() {
        if whooopLabel.hidden {
            infoLabel.text = "LET \(numberOfFriends) OF YOUR\nFRIENDS KNOW"
        } else {
            infoLabel.text = "\(numberOfFriends) FRIENDS\nNOTIFIED"
        }
    }
    
    // MARK: - Data
    func numberOfSelectedFriendsDidChange() {
        if numberOfFriends != FacebookData.sharedInstance.selectedFriends.count {
            numberOfFriends = FacebookData.sharedInstance.selectedFriends.count
            refreshLabel()
        }
    }
    
    func pushToServer() {
        for friendId in FacebookData.sharedInstance.selectedFriends {
            let reference = databaseRefrence.child(friendId).childByAutoId()
            let post = ["user_id": FacebookData.sharedInstance.userID,
                        "user_first_name": FacebookData.sharedInstance.userFirstName,
                        "user_display_name": FacebookData.sharedInstance.userName,
                        "timestamp": Int(NSDate().timeIntervalSince1970)]
            reference.setValue(post)
        }
    }
}
