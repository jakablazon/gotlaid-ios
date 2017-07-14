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
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return RootViewController.statusBarAnimation
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfStaticCells + FacebookData.sharedInstance.friends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        if indexPath.row == 0 {
            identifier = "FriendCellTop"
        } else {
            identifier = "FriendCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! FriendCell
        
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
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedId = FacebookData.sharedInstance.friends[indexPath.row - numberOfStaticCells].id
        FacebookData.sharedInstance.selectedFriends.insert(selectedId)
        FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedId = FacebookData.sharedInstance.friends[indexPath.row - numberOfStaticCells].id
        FacebookData.sharedInstance.selectedFriends.remove(selectedId)
        FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.row < numberOfStaticCells {
            (tableView.cellForRow(at: indexPath) as! FriendCell).animateTransitionHighlited()
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.row < numberOfStaticCells {
            (tableView.cellForRow(at: indexPath) as! FriendCell).animateTransitionUnHighlited()
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            if let indexPaths = tableView.indexPathsForSelectedRows {
                for indexPath in indexPaths {
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
            
            FacebookData.sharedInstance.selectedFriends.removeAll()
            FacebookData.sharedInstance.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
            
            return nil
        } else if indexPath.row == 1 {
            for i in numberOfStaticCells..<tableView.numberOfRows(inSection: 0) {
                tableView.selectRow(at: IndexPath(item: i, section: 0), animated: false, scrollPosition: .none)
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
