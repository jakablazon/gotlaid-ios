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
    
    let databaseRefrence = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        laidButton.titleLabel?.textAlignment = .center
        laidButton.layer.cornerRadius = 108
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(laidButtonCancel))
        view.addGestureRecognizer(tap)
        
        refreshLabel()
        
        FacebookData.sharedInstance.selectedFriendsDelegate = self
    }
    
    // MARK: - Status Bar
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return RootViewController.statusBarAnimation
    }
    
    // MARK: - Logout
    @IBAction func logoutButtonPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
        } catch _ {}
        FBSDKLoginManager().logOut()
        
        FacebookData.sharedInstance.friends.removeAll()
        FacebookData.sharedInstance.selectedFriends.removeAll()
    }
    
    // MARK: - Laid Button
    func laidButtonCancel(_ sender: AnyObject) {
        if !initialState {
            initialState = true
            laidButton.setTitle("I JUST\nGOT LAID", for: UIControlState())
        }
    }
    
    @IBAction func laidButtonPressed(_ sender: AnyObject) {
        if initialState {
            laidButton.setTitle("YOU\nSURE?", for: UIControlState())
            initialState = false
        } else {
            pushToServer()
            
            displayWhooopLabel()
            
            let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.hideWhooopLabel()
            }
            
            if numberOfFriends == 1 {
                infoLabel.text = "\(numberOfFriends) FRIEND\nNOTIFIED"
            } else {
                infoLabel.text = "\(numberOfFriends) FRIENDS\nNOTIFIED"
            }
            
            initialState = true
        }
    }
    
    // MARK: - Label Animations
    func displayWhooopLabel() {
        whooopLabel.alpha = 0.0
        whooopLabel.isHidden = false
        UIView.animate(withDuration: animationTime,
                                   animations: {
                                    self.whooopLabel.alpha = 1.0
                                    self.laidButton.alpha = 0.0
                                   }, completion: {_ in
                                    self.laidButton.isHidden = true
        })
    }
    
    func hideWhooopLabel() {
        laidButton.isHidden = false
        laidButton.setTitle("I JUST\nGOT LAID", for: UIControlState())
        UIView.animate(withDuration: animationTime,
                                   animations: {
                                    self.whooopLabel.alpha = 0.0
                                    self.laidButton.alpha = 1.0
                                  }, completion: {_ in
                                    self.whooopLabel.isHidden = true
        })
        
        infoLabel.text = "LET \(numberOfFriends) OF YOUR\nFRIENDS KNOW"
    }
    
    func refreshLabel() {
        if whooopLabel.isHidden {
            infoLabel.text = "LET \(numberOfFriends) OF YOUR\nFRIENDS KNOW"
        } else {
            if numberOfFriends == 1 {
                infoLabel.text = "\(numberOfFriends) FRIEND\nNOTIFIED"
            } else {
                infoLabel.text = "\(numberOfFriends) FRIENDS\nNOTIFIED"
            }
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
                        "timestamp": Int(Date().timeIntervalSince1970)] as [String : Any]
            reference.setValue(post)
        }
    }
}
