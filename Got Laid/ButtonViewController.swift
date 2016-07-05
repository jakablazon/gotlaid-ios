//
//  ViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/4/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit

class ButtonViewController: UIViewController {
    @IBOutlet weak var laidButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var whooopLabel: UILabel!
    
    let animationTime = 0.3
    let delay = 3.0
    
    // TODO: implement number of friends
    let numberOfFriends = 345
    
    var initialState = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        laidButton.titleLabel?.textAlignment = .Center
        laidButton.layer.cornerRadius = 108
    }
    
    @IBAction func laidButtonPressed(sender: AnyObject) {
        if initialState {
            laidButton.setTitle("YOU\nSURE?", forState: .Normal)
            initialState = false
        } else {
            // TODO: push got laid to server
            displayWhooopLabel()
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.hideWhooopLabel()
            }
            
            self.infoLabel.text = "\(numberOfFriends) FRIENDS\nNOTIFIED"
            initialState = true
        }
    }
    
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
        
        self.infoLabel.text = "LET \(numberOfFriends) OF YOUR\nFRINDS KNOW"
    }
}
