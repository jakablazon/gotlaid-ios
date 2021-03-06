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

struct Friend: Hashable {
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
    
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: Friend, rhs: Friend) -> Bool {
    return lhs.id == rhs.id
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
        userID = FBSDKProfile.current()?.userID ?? ""
        userName = FBSDKProfile.current()?.name ?? ""
        userFirstName = FBSDKProfile.current()?.firstName ?? ""
    }
    
    func getFriends() {
        if downloading {
            return
        }
        downloading = true
        
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, name"])
        let _ = request?.start { (connection, result, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                self.downloading = false
                return
            }
            
            let dictionary = result as! [String: AnyObject]
            let data = dictionary["data"] as! [[String: String]]
            
            var friendsIdSet = Set<String>()
            var newFriends = [Friend]()
            
            for dataEntry in data {
                let friend = Friend(dictionary: dataEntry)
                newFriends.append(friend)
                friendsIdSet.insert(friend.id)
            }
            
            let removedFriends = self.selectedFriends.subtracting(friendsIdSet)
            for removedFriend in removedFriends {
                self.selectedFriends.remove(removedFriend)
            }
            
            let newFriendsSet = Set(newFriends)
            let oldFriendsSet = Set(self.friends)
            
            let addedFriends = newFriendsSet.subtracting(oldFriendsSet)
            for addedFriend in addedFriends {
                self.selectedFriends.insert(addedFriend.id)
            }
            
            self.friends = newFriends
            
            self.downloading = false
            self.friendsDelegate?.friendsDidDownload()
            self.selectedFriendsDelegate?.numberOfSelectedFriendsDidChange()
        }
    }
    
    func load() {
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask,
            true).first!)
        
        let friendsPath = documentsPath.appendingPathComponent("friends.plist")
        let selectedFriendsPath = documentsPath.appendingPathComponent("selected_friends.plist")
        
        friends.removeAll()
        
        if let rawFriends = NSArray(contentsOf: friendsPath) as? [[String: String]] {
            for rawFriend in rawFriends {
                let friend = Friend(dictionary: rawFriend)
                friends.append(friend)
            }
            
            friends.sort(by: {$0.name < $1.name})
        }
        
        if let rawSelectedFriends = NSArray(contentsOf: selectedFriendsPath) as? [String] {
            selectedFriends = Set(rawSelectedFriends)
        }
    }
    
    func save() {
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask,
            true).first!)
        
        let friendsPath = documentsPath.appendingPathComponent("friends.plist")
        let selectedFriendsPath = documentsPath.appendingPathComponent("selected_friends.plist")
        
        var friendsDictionaryArray = [[String: String]]()
        for friend in friends {
            friendsDictionaryArray.append(friend.dictionary)
        }
        
        NSArray(array: friendsDictionaryArray).write(to: friendsPath, atomically: true)
        NSArray(array: Array(selectedFriends)).write(to: selectedFriendsPath, atomically: true)
    }
    
}

