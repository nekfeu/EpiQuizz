//
//  ContributeController.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 23/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit

class ContributeController: UIViewController {

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var questionText: String!
    var arrayAsk = ["toto", "toto", "toto", "toto"]
    var answerOne: String!
    var answerTwo: String!
    var answerThree: String!
    var answerFour: String!
    var step = 1
    var correctAnswer : Int!
    var sentence = "Entre une mauvaise proposition ici"
    var sentenceTrue = "Entre la bonne réponse ici"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctAnswer = giveRandom()
    }
    
    func giveRandom() -> Int {
        var randomNumber = Int(arc4random_uniform(4))
        return randomNumber
    }
    
    func contributeResponse(response: HTTPResponse) {
        
    }
    
    func submitContribute() {
        var nbArray = [0, 1, 2, 3]
        var content = [answerOne, answerTwo, answerThree, answerFour]
        var random = giveRandom()
        correctAnswer = random + 1
        arrayAsk[random] = answerOne
        nbArray.removeAtIndex(random)
        for element in nbArray {
            arrayAsk[element] = content[element]
        }
        var request = HTTPTask()
        request.requestSerializer = JSONRequestSerializer()
        request.responseSerializer = JSONResponseSerializer()
        let params: Dictionary<String,AnyObject> = ["ask": questionText, "answer_one": answerOne, "answer_two": answerTwo, "answer_three": answerThree, "answer_four": answerFour, "real_answer": correctAnswer]
        print(params)
       // request.POST("http://188.165.251.47:3000/epiquizz/add", parameters: params, completionHandler: contributeResponse)
    }
    
    func saveValue(stepNb: Int) {
        if (stepNb == 1) {
            questionText = inputField.text
            inputField.text = ""
            inputField.placeholder = sentenceTrue
        } else if (stepNb == 2) {
            answerOne = inputField.text
            inputField.text = ""
            inputField.placeholder = sentence
        } else if (stepNb == 3) {
            answerTwo = inputField.text
            inputField.text = ""
            inputField.placeholder = sentence
        } else if (stepNb == 4) {
            answerThree = inputField.text
            inputField.text = ""
            inputField.placeholder = sentence
        } else if (stepNb == 5) {
            answerFour = inputField.text
            inputField.removeFromSuperview()
            nextButton.backgroundColor = UIColor(rgba: "#2ecc71")
            nextButton.setTitle("Valider", forState: UIControlState.Normal)
        } else if (stepNb == 6) {
            submitContribute()
        }
    }
    
    func nextStep(stepNb: Int) {
        
    }
    
    @IBAction func nextBtn(sender: UIButton) {
        saveValue(step)
        step++
    }
    
    @IBAction func cancelBtn(sender: UIButton) {
        let vcc = self.storyboard!.instantiateViewControllerWithIdentifier("HomeController") as! HomeController
        self.presentViewController(vcc, animated: true, completion: nil)
    }
}
