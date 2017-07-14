//
//  FriendCell.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/6/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var animating = false
    var animationQue: [()->()] = []
    let animationDuration = 0.15
    
    func animateTransitionHighlited() {
        let animation = {
            UIView.animate(withDuration: self.animationDuration,
                                       animations: {
                                        self.containerView.layer.backgroundColor =
                                            UIColor(red: 224/255.0, green: 224/255.0, blue: 224/255.0, alpha: 1.0).cgColor
                }, completion: {finished in
                    self.animating = false
                    self.nextAnimation()
            })
        }
        animationQue.append(animation)
        nextAnimation()
    }
    
    func animateTransitionUnHighlited() {
        let animation = {
            UIView.animate(withDuration: self.animationDuration,
                                       animations: {
                                        self.containerView.layer.backgroundColor = UIColor.white.cgColor
                }, completion: {finished in
                    self.animating = false
                    self.nextAnimation()
            })
        }
        animationQue.append(animation)
        nextAnimation()
    }
    
    func cancelAnimations() {
        animationQue.removeAll()
    }
    
    func nextAnimation() {
        if animationQue.first != nil && !animating {
            animating = true
            animationQue.remove(at: 0)()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        
        if selected {
            containerView.backgroundColor = UIColor.black
            nameLabel.textColor = UIColor.white
        } else {
            containerView.backgroundColor = UIColor.white
            nameLabel.textColor = UIColor.black
        }
    }
}
