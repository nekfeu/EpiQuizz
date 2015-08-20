//
//  ClassementController.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 16/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit

class ClassementController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var classementView: UICollectionView!
    
    var nbUsers: Int?
    var scoreArray: Array<AnyObject>!
    var defaultValue = 0
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestClassement()
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
                self.classementView.reloadData()
            }
        }
    }
    
    func requestClassement() {
        var request = HTTPTask()
        request.requestSerializer = JSONRequestSerializer()
        request.responseSerializer = JSONResponseSerializer()
        request.GET("http://188.165.251.47:3000/epiquizz/list", parameters: nil, completionHandler: getLeaderboard)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return defaultValue
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        var  cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! myViewCell
        print(indexPath.row)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var  cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! myViewCell

        if (scoreArray != nil) {
        if let contentArray = scoreArray[indexPath.row] as? Dictionary<String, AnyObject> {
            cell.nameLabel.text = contentArray["name"] as? String
            var scoreContent = contentArray["score"] as! Int
            cell.scoreLabel.text = "\(scoreContent) / 30"
            cell.cityLabel.text = contentArray["city"] as? String
            var timeContent = contentArray["time"] as! Int
            cell.timeLabel.text = "\(timeContent)s"
        }
        //Do your customization here
        }
        return cell
    }

}
