//
//  ProfileController.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 19/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var loginField: UITextField!
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var shortCity: Array<String> = ["PAR","BDX","NCY", "MAR", "LYN", "TLS", "NCE", "STG", "REN", "LIL", "MPL", "NAN"]
    var longCity: Array<String> = ["Paris","Bordeaux","Nancy", "Marseille", "Lyon", "Toulouse", "Nice", "Strasbourg", "Rennes", "Lille", "Montpellier", "Nantes"]
    var currentCity: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var userLogin: String? = self.userDefaults.objectForKey("userLogin") as! String?
        var userCity: String? = self.userDefaults.objectForKey("userCity") as! String?
        
        if (userLogin != nil) {
            loginField.text = userLogin
        }
        
        if (userCity != nil) {
            if let index = find(shortCity, userCity!) {
                 picker.selectRow(index, inComponent: 0, animated: false)
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return longCity.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return longCity[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        currentCity = shortCity[row]
    }
    
    func checkLogin() -> Bool {
        var loginText = loginField.text
        if loginText.rangeOfString("_") == nil{
            JLToast.makeText("Merci d'entrer un login valide", duration: JLToastDelay.LongDelay).show()
            return false
        } else {
            return true
        }
        // request /user et on voit.
    }
    
    @IBAction func saveData(sender: UIButton) {
        if checkLogin() == true {
            self.userDefaults.setObject(loginField.text, forKey: "userLogin")
            self.userDefaults.setObject(currentCity, forKey: "userCity")
            JLToast.makeText("Enregistrement effectué !", duration: JLToastDelay.ShortDelay).show()
        }
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}