//
//  AskList.swift
//  EpiQuizz
//
//  Created by Kevin Empociello on 16/08/15.
//  Copyright (c) 2015 Kevin Empociello. All rights reserved.
//

import UIKit

class AskList {
    var questions: NSArray = NSArray()
    init() {
        if let path = NSBundle.mainBundle().pathForResource("questions", ofType: "json") {
            if let jsonData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil) {
                if let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    if let persons : NSArray = jsonResult["questions"] as? NSArray {
                        questions = persons
                        print(questions)
                        // Do stuff
                    }
                }
            }
        }
    }
}

