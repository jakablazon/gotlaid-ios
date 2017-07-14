//
//  LoginViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/5/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBSDKProfile.enableUpdates(onAccessTokenChange: true)
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["public_profile", "email", "user_friends"],
                                       from: self, handler: {
                                        (result, error) in
                                        if error != nil {
                                            self.displayError("Could not sign in.")
                                        } else if (result?.isCancelled)! {
                                            self.displayError("You must sign in to use the app.")
                                        } else {
                                            let credential = FacebookAuthProvider
                                                .credential(withAccessToken: FBSDKAccessToken.current()
                                                    .tokenString)
                                            Auth.auth().signIn(with: credential) {
                                                (user, error) in
                                                if error != nil {
                                                    self.displayError("Could not sign in.")
                                                } else {
                                                    FacebookData.sharedInstance.getFbProfileData()
                                                    FacebookData.sharedInstance.getFriends()
                                                    self.dismiss(animated: true, completion: nil)
                                                }
                                            }
                                        }
                                        
        })
    }
    
    func displayError(_ errorMessage: String) {
        let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
