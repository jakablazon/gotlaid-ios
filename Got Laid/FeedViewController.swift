//
//  FeedViewController.swift
//  Got Laid
//
//  Created by Vid Drobnič on 7/6/16.
//  Copyright © 2016 Povio Labs. All rights reserved.
//

import UIKit
import FirebaseDatabase
import DateTools

struct Data {
    var time: NSDate
    var name: String
    
    init(dictionary: [String: AnyObject]) {
        let timestamp = dictionary["timestamp"] as! Double
        time = NSDate(timeIntervalSince1970: timestamp)
        name = dictionary["user_first_name"] as! String
        name = name.uppercaseString
    }
}

class FeedViewController: UITableViewController {
    let databaseRefrence = FIRDatabase.database().reference()
    
    var data = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRefrence.child(FacebookData.sharedInstance.userID)
            .queryLimitedToLast(100).observeEventType(.ChildAdded, withBlock: databaseObserver)
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
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedCell
        
        let dataEntry = data[indexPath.row]
        
        let timeString = dataEntry.time.shortTimeAgoSinceNow()
            .stringByReplacingOccurrencesOfString("m", withString: "min")
            .uppercaseString
        
        cell.mainLabel.text = "\(dataEntry.name) GOT LAID! \(timeString) AGO"
        
        return cell
    }

    // MARK: - Data
    func databaseObserver(snapshot: FIRDataSnapshot) {
        let dataEntry = Data(dictionary: snapshot.value as! [String: AnyObject])
        data.insert(dataEntry, atIndex: 0)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
}
