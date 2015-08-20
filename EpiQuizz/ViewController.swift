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
                print("Good answer")
                scoreValue++
            } else {
                print("Wrong answer")
            }
            questionDone++
            updateScore()
            updateQuestion()
        }
    }
    
    func updateTime() {
        countingLabel.text = "\(String(counter++))s"
    }
    
    func updateQuestion() {
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

