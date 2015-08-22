//
//  ClassementView.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 19/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit

class ClassementView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl:UIRefreshControl!
    var nbUsers: Int?
    var scoreArray: Array<AnyObject>!
    var defaultValue = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        requestClassement()
    }
    
    func refresh(sender:AnyObject)
    {
        requestClassement()
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        // Code to refresh table view
    }
    
    func putAlertBox(titleMessage: String, messageMessage: String) {
        var refreshAlert = UIAlertController(title: titleMessage, message: messageMessage, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            println("AlertBox is display")
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func getLeaderboard(response: HTTPResponse) {
        if let err = response.error {
            println("error: \(err.localizedDescription)")
            return
        }
        if let dict = response.responseObject as? Dictionary<String,AnyObject> {
            scoreArray = dict["scores"] as! Array<AnyObject>
            defaultValue = dict["nbLines"] as! Int
            print(scoreArray)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    func requestClassement() {
        var request = HTTPTask()
        request.requestSerializer = JSONRequestSerializer()
        request.responseSerializer = JSONResponseSerializer()
        request.GET("http://188.165.251.47:3000/epiquizz/list", parameters: nil, completionHandler: getLeaderboard)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return defaultValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("myCellTable", forIndexPath: indexPath) as! myCellTable
        if (scoreArray != nil) {
            if let contentArray = scoreArray[indexPath.row] as? Dictionary<String, AnyObject> {
                if (indexPath.row == 0) {
                    cell.backgroundColor = UIColor(rgba: "#2ECC71")
                } else {
                    cell.backgroundColor = UIColor(rgba: "#3498DB")
                }
                cell.nameLabel.text = contentArray["name"] as? String
                var scoreContent = contentArray["score"] as! Int
                cell.scoreLabel.text = "\(scoreContent)/30"
                cell.cityLabel.text = contentArray["city"] as? String
                var timeContent = contentArray["time"] as! Int
                cell.timeLabel.text = "\(timeContent)s"
            }
            //Do your customization here
        }
        return cell

    }
    
}

