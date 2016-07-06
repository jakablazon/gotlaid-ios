//
//  FriendsViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/6/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit

class FriendsViewController: UITableViewController, FacebookDataFriendsDelegate {
    let numberOfStaticCells = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FacebookData.sharedInstance.friendsDelegate = self
    }
    
    // MARK: - Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return RootViewController.statusBarAnimation
    }
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfStaticCells + FacebookData.sharedInstance.friends.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier: String
        if indexPath.row == 0 {
            identifier = "FriendCellTop"
        } else {
            identifier = "FriendCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! FriendCell
        
        if indexPath.row == 0 {
            cell.nameLabel.text = "DESELECT ALL"
        } else if indexPath.row == 1 {
            cell.nameLabel.text = "SELECT ALL"
        } else {
            let index = indexPath.row - numberOfStaticCells
            let friend = FacebookData.sharedInstance.friends[index]
            
            cell.nameLabel.text = friend.name
            
            let id = friend.id
            if FacebookData.sharedInstance.selectedFriends.contains(id) {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedId = FacebookData.sharedInstance.friends[indexPath.row - numberOfStaticCells].id
        FacebookData.sharedInstance.selectedFriends.insert(selectedId)
        FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedId = FacebookData.sharedInstance.friends[indexPath.row - numberOfStaticCells].id
        FacebookData.sharedInstance.selectedFriends.remove(selectedId)
        FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
    }
    
    override func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < numberOfStaticCells {
            (tableView.cellForRowAtIndexPath(indexPath) as! FriendCell).animateTransitionHighlited()
        }
    }
    
    override func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < numberOfStaticCells {
            (tableView.cellForRowAtIndexPath(indexPath) as! FriendCell).animateTransitionUnHighlited()
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == 0 {
            if let indexPaths = tableView.indexPathsForSelectedRows {
                for indexPath in indexPaths {
                    tableView.deselectRowAtIndexPath(indexPath, animated: false)
                }
            }
            
            FacebookData.sharedInstance.selectedFriends.removeAll()
            FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
            
            return nil
        } else if indexPath.row == 1 {
            for i in numberOfStaticCells..<tableView.numberOfRowsInSection(0) {
                tableView.selectRowAtIndexPath(NSIndexPath(forItem: i, inSection: 0), animated: false, scrollPosition: .None)
                let friend = FacebookData.sharedInstance.friends[i - numberOfStaticCells]
                FacebookData.sharedInstance.selectedFriends.insert(friend.id)
            }
            
            FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
            
            return nil
        }
        
        return indexPath
    }
    
    // MARK: - Facebook Data
    func friendsDidDownload() {
        tableView.reloadData()
    }
}
