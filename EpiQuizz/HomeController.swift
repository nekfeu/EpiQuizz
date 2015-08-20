//
//  HomeController.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 19/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()

    func putAlertBox(titleMessage: String, messageMessage: String) {
        var refreshAlert = UIAlertController(title: titleMessage, message: messageMessage, preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            self.checkInternet()
        }))
        presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func checkInternet() {
        if (Reachability.isConnectedToNetwork() == false) {
            putAlertBox("Erreur Internet", messageMessage: "Active ta connexion internet s'il te plait, on l'utilise pour le classement national mais aussi pour mettre à jours les questions")
        } else {
            print("ta internet")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (Reachability.isConnectedToNetwork() == false) {
            putAlertBox("Erreur Internet", messageMessage: "Active ta connexion internet s'il te plait, on l'utilise pour le classement national mais aussi pour mettre à jours les questions")
        }
        checkInternet()
        var userLogin: String? = self.userDefaults.objectForKey("userLogin") as! String?
        var userCity: String? = self.userDefaults.objectForKey("userCity") as! String?
        if (userLogin == nil || userCity == nil) {
            let vcc = self.storyboard!.instantiateViewControllerWithIdentifier("ProfileController") as! ProfileController
            self.presentViewController(vcc, animated: true, completion: nil)
            JLToast.makeText("Merci d'entrer votre login et votre ville", duration: JLToastDelay.LongDelay).show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
