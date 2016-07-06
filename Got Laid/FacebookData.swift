//
//  FriendList.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/5/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import Foundation
import FBSDKCoreKit


protocol FacebookDataFriendsDelegate {
    func friendsDidDownload()
}

protocol FacebookDataSelectedFriendsDelegate {
    func numberOfSelectedFriendsDidChange()
}

struct Friend {
    var name: String
    var id: String
    
    init() {
        name = ""
        id = ""
    }
    
    init(dictionary: [String: String]) {
        name = dictionary["name"]!
        id = dictionary["id"]!
    }
    
    var dictionary: [String: String] {
        return ["name": name,
                "id": id]
    }
}

final class FacebookData {
    static let sharedInstance = FacebookData()
    
    var userID = ""
    var userName = ""
    var userFirstName = ""
    
    var friends = [Friend]()
    var selectedFriends = Set<String>()
    
    var downloading = false
    
    var friendsDelegate: FacebookDataFriendsDelegate?
    var selectedFriendsDelegate: FacebookDataSelectedFriendsDelegate?
    
    init() {
        load()
        getFriends()
        getFbProfileData()
    }
    
    func getFbProfileData() {
        userID = FBSDKProfile.currentProfile()?.userID ?? ""
        userName = FBSDKProfile.currentProfile()?.name ?? ""
        userFirstName = FBSDKProfile.currentProfile()?.firstName ?? ""
    }
    
    func getFriends() {
        if downloading {
            return
        }
        downloading = true
        
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, name"])
        request.startWithCompletionHandler { (connection, result, error) in
            if error != nil {
                print(error.localizedDescription)
                self.downloading = false
                return
            }
            
            let dictionary = result as! [String: AnyObject]
            let data = dictionary["data"] as! [[String: String]]
            
            var friendsSet = Set<String>()
            
            self.friends.removeAll()
            for dataEntry in data {
                let friend = Friend(dictionary: dataEntry)
                self.friends.append(friend)
                friendsSet.insert(friend.id)
            }
            
            let removedFriends = self.selectedFriends.subtract(friendsSet)
            for removedFriend in removedFriends {
                self.selectedFriends.remove(removedFriend)
            }
            
            self.downloading = false
            self.friendsDelegate?.friendsDidDownload()
        }
    }
    
    func load() {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask,
            true).first!)
        
        let friendsPath = documentsPath.URLByAppendingPathComponent("friends.plist")
        let selectedFriendsPath = documentsPath.URLByAppendingPathComponent("selected_friends.plist")
        
        friends.removeAll()
        
        if let rawFriends = NSArray(contentsOfURL: friendsPath) as? [[String: String]] {
            for rawFriend in rawFriends {
                let friend = Friend(dictionary: rawFriend)
                friends.append(friend)
            }
            
            friends.sortInPlace({$0.name < $1.name})
        }
        
        if let rawSelectedFriends = NSArray(contentsOfURL: selectedFriendsPath) as? [String] {
            selectedFriends = Set(rawSelectedFriends)
        }
    }
    
    func save() {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask,
            true).first!)
        
        let friendsPath = documentsPath.URLByAppendingPathComponent("friends.plist")
        let selectedFriendsPath = documentsPath.URLByAppendingPathComponent("selected_friends.plist")
        
        var friendsDictionaryArray = [[String: String]]()
        for friend in friends {
            friendsDictionaryArray.append(friend.dictionary)
        }
        
        NSArray(array: friendsDictionaryArray).writeToURL(friendsPath, atomically: true)
        NSArray(array: Array(selectedFriends)).writeToURL(selectedFriendsPath, atomically: true)
    }
    
}

