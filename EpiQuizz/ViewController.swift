//
//  ViewController.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 16/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var fourthResponseLabel: UIButton!
    @IBOutlet weak var thirdResponseLabel: UIButton!
    @IBOutlet weak var secondResponseLabel: UIButton!
    @IBOutlet weak var firstResponseLabel: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countingLabel: UILabel!
    
    var questionsList = AskList()
    var timer = NSTimer()
    var arrayDone = Array<Int>()
    var currentAnswer: Int?
    var questionDone = 0
    var scoreValue = 0
    var textField = UITextField()
    var progressHUD : ProgressRound?
    var userLogin: String?
    var userCity: String?
    var counter = 0
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userLogin = self.userDefaults.objectForKey("userLogin") as! String?
        userCity = self.userDefaults.objectForKey("userCity") as! String?
        if (userLogin == nil || userCity == nil) {
            print("Error login or user city pas la")
        }
        questionsList = AskList()
        updateQuestion()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateTime"), userInfo: nil, repeats: true)
    }
    
    @IBAction func skipQuestion(sender: UIButton) {
        questionDone++
        updateScore()
        updateQuestion()
    }
    
    @IBAction func answerOne(sender: UIButton) {
        checkAnswer(1)
    }
    
    @IBAction func answerTwo(sender: UIButton) {
        checkAnswer(2)
    }
    
    @IBAction func answerThird(sender: UIButton) {
        checkAnswer(3)
    }
    
    @IBAction func answerFourth(sender: UIButton) {
        checkAnswer(4)
    }
    
    func checkRandom(nb: Int) -> Bool {
        for element in arrayDone {
            if (nb == element) {
                return true
            }
        }
        return false
    }
    
    func giveRandom() -> Int {
        var randomNumber = Int(arc4random_uniform(39) + 1)
        while (checkRandom(randomNumber) == true && questionDone < 39) {
            randomNumber = Int(arc4random_uniform(39) + 1)
        }
        arrayDone.append(randomNumber)
        return randomNumber
    }
    
    func configurationTextField(textField: UITextField!)
    {
        println("configurat hire the TextField")
        if let tField = textField {
            self.textField = textField!        //Save reference to the UITextField
            self.textField.text = "Hello world"
        }
    }
    
    func handleCancel(alertView: UIAlertAction!)
    {
        let vcc = self.storyboard!.instantiateViewControllerWithIdentifier("HomeController") as! HomeController
        self.presentViewController(vcc, animated: true, completion: nil)
    }
    
    func putAlertBox(titleMessage: String, messageMessage: String) {
        var refreshAlert = UIAlertController(title: titleMessage, message: messageMessage, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            println("AlertBox is display")
            if (titleMessage == "Score envoyé !") {
                let vcc = self.storyboard!.instantiateViewControllerWithIdentifier("HomeController") as! HomeController
                self.presentViewController(vcc, animated: true, completion: nil)
            }
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func sendScoreResponse (response:HTTPResponse){
        if let err = response.error {
            println("error: \(err.localizedDescription)")
            return
        }
        if let dict = response.responseObject as? Dictionary<String,AnyObject> {
            println(dict["status"]!)
            println(dict)
            var status = dict["status"] as! Int
            if (status == 1) {
                var errorArray = dict["message"] as! Array<AnyObject>
                println(errorArray[0])
                if let dictError = errorArray[0] as? Dictionary<String, AnyObject> {
                    self.putAlertBox("On a un problème !", messageMessage: dictError["message"]! as! String)
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressHUD?.removeFromSuperview()
                }
                self.putAlertBox("Score envoyé !", messageMessage: "Allez voir le classement... Vous y apparaîssez peut-être.")
                // HOME BACK
            }
        }
    }
    
    func sendScore(alertView: UIAlertAction!)
    {
        if (scoreValue > 30) {
            self.putAlertBox("Cheater", messageMessage: "J'ai ton login je te met -42 direct.")
        } else {
            self.progressHUD = ProgressRound(text: "Envoi")
            self.view.addSubview(self.progressHUD!)
            // Ok on send la requete
            var request = HTTPTask()
            request.requestSerializer = JSONRequestSerializer()
            request.responseSerializer = JSONResponseSerializer()
            let params: Dictionary<String,AnyObject> = ["name": userLogin!, "score": scoreValue, "city": userCity!, "time": counter]
            request.POST("http://188.165.251.47:3000/epiquizz/add", parameters: params, completionHandler: sendScoreResponse)
        }
    }
    
    func animationAnswer(answer: Bool, reinit: Bool) {
        var color : UIColor!
        if (answer == true) {
           color = UIColor(rgba: "#2ecc71")
        } else {
            color = UIColor(rgba: "#ea6153")
        }
        if (reinit == true) {
            color = UIColor(rgba: "#6BB9F0")
        }
        UIView.animateWithDuration(0.5, animations:{
            self.firstResponseLabel.backgroundColor = color
            self.secondResponseLabel.backgroundColor = color
            self.thirdResponseLabel.backgroundColor = color
            self.fourthResponseLabel.backgroundColor = color
        }, completion: {(finished:Bool) in
            UIView.animateWithDuration(0.5, animations:{
                self.firstResponseLabel.backgroundColor = UIColor(rgba: "#6BB9F0")
                self.secondResponseLabel.backgroundColor = UIColor(rgba: "#6BB9F0")
                self.thirdResponseLabel.backgroundColor = UIColor(rgba: "#6BB9F0")
                self.fourthResponseLabel.backgroundColor = UIColor(rgba: "#6BB9F0")
                }, completion: {(finished:Bool) in
                    self.questionDone++
                    self.updateScore()
                    self.updateQuestion()
            })
        })
    }
    
    func checkAnswer(nbAnswer: Int) {
        if (questionDone == 29) {
            timer.invalidate()
            var alert = UIAlertController(title: "Ton Score : \(scoreValue)/30 en \(counter)sec", message: "Envoi ton score et va voir le classement national !", preferredStyle: UIAlertControllerStyle.Alert)
            //alert.addTextFieldWithConfigurationHandler(configurationTextField)
            alert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.Cancel, handler:handleCancel))
            alert.addAction(UIAlertAction(title: "J'envoi", style: UIAlertActionStyle.Default, handler:sendScore))
            self.presentViewController(alert, animated: true, completion: {
                println("completion block")
            })
        } else {
            if (currentAnswer == nbAnswer) {
                animationAnswer(true, reinit: false)
                print("Good answer")
                scoreValue++
            } else {
                animationAnswer(false, reinit: false)
                print("Wrong answer")
            }
        }
    }
    
    func updateTime() {
        countingLabel.text = "\(String(counter++))s"
    }
    
    func updateQuestion() {
        //animationAnswer(false, reinit: true)
        var randomNb = giveRandom()
        currentAnswer = questionsList.questions[randomNb].valueForKey("real_answer") as? Int
        questionLabel.text = questionsList.questions[randomNb].valueForKey("ask") as? String
        firstResponseLabel.setTitle(questionsList.questions[randomNb].valueForKey("answer_one") as? String, forState: UIControlState.Normal)
        secondResponseLabel.setTitle(questionsList.questions[randomNb].valueForKey("answer_two") as? String, forState: UIControlState.Normal)
        thirdResponseLabel.setTitle(questionsList.questions[randomNb].valueForKey("answer_three") as? String, forState: UIControlState.Normal)
        fourthResponseLabel.setTitle(questionsList.questions[randomNb].valueForKey("answer_four") as? String, forState: UIControlState.Normal)
    }
    
    func updateScore() {
        scoreLabel.text = "Score : \(scoreValue) / 30"
    }
    
}

extension UIView {
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 1.0
            }, completion: completion)  }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.alpha = 0.0
            }, completion: completion)
    }
}

extension UIColor {
    public convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}