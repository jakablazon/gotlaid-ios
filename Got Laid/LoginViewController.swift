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
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email", "user_friends"],
                                       fromViewController: self, handler: {
                                        (result, error) in
                                        if error != nil {
                                            self.displayError("Could not sign in.")
                                        } else if result.isCancelled {
                                            self.displayError("You must sign in to use the app.")
                                        } else {
                                            let credential = FIRFacebookAuthProvider
                                                .credentialWithAccessToken(FBSDKAccessToken.currentAccessToken()
                                                    .tokenString)
                                            FIRAuth.auth()?.signInWithCredential(credential) {
                                                (user, error) in
                                                if error != nil {
                                                    self.displayError("Could not sign in.")
                                                } else {
                                                    self.dismissViewControllerAnimated(true, completion: nil)
                                                }
                                            }
                                        }
                                        
        })
    }
    
    func displayError(errorMessage: String) {
        let alertController = UIAlertController(title: nil, message: errorMessage, preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
        alertController.addAction(dismissAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
