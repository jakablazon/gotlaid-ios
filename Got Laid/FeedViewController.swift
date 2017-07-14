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
    var time: Date
    var name: String
    
    init(dictionary: [String: AnyObject]) {
        let timestamp = dictionary["timestamp"] as! Double
        time = Date(timeIntervalSince1970: timestamp)
        name = dictionary["user_first_name"] as! String
        name = name.uppercased()
    }
}

class FeedViewController: UITableViewController {
    var data = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseReference = Database.database().reference()
        let readReference = databaseReference.child(FacebookData.sharedInstance.userID)
        
        readReference.queryLimited(toLast: 100).observe(.childAdded, with: databaseAddObserver)
        readReference.queryLimited(toLast: 100).observe(.childRemoved, with: databaseRemoveObserver)
        
        readReference.keepSynced(true)
        
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTableView),
                                               userInfo: nil, repeats: true)
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
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        let dataEntry = data[indexPath.row]
        
        let timeString = (dataEntry.time as NSDate).timeAgoSinceNow().uppercased()
        
        cell.mainLabel.text = "\(dataEntry.name) GOT LAID! \(timeString)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: - Data
    func databaseAddObserver(_ snapshot: DataSnapshot) {
        let dataEntry = Data(dictionary: snapshot.value as! [String: AnyObject])
        data.insert(dataEntry, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func databaseRemoveObserver(_ snapshot: DataSnapshot) {
        data.removeLast()
        
        let indexPath = IndexPath(row: data.count, section: 0)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
}
