//
//  Customs+Extensions.swift
//  QuizGame(1)
//
//  Created by Ross on 07/11/2017.
//  Copyright © 2017 Ross. All rights reserved.
//

import Foundation
import UIKit

extension Array {

    mutating func shuffle() {
        if count < 2 {return}
        for i in 0..<(count-1) {
            var j = 0
            while j == i {
                j = Int(arc4random_uniform(UInt32(count - i))) + i
            }
            swap (&self[i], &self[j])
        }
    }
}

let multipleChoiceHighScoreIdentifier = "MultipleChoiceHighScoreIdentifier"
let multipleChoiceRecentScoreIdentifier = "MultipleChoiceRecentScoreIdentifier"

let imageQuizHighScoreIdentifier = "ImageQuizHighHighScoreIdentifier"
let imageQuizRecentScoreIdentifier = "ImageQuizRecentScoreIdentifier"

let rightWrongHighScoreIdentifier = "RightWrongHighScoreIdentifier"
let rightWrongRecentScoreIdentifier = "RightWrongRecentScoreIdentifier"

let emojiHighScoreIdentifier = "EmojiHighScoreIdentifier"
let emojiRecentScoreIdentifier = "EmojiRecentScoreIdentifier"

let flatGreen = UIColor.init(red: 46/255, green: 204/255, blue: 113/255, alpha: 0.1)
let flatOrange = UIColor.init(red: 230/255, green: 126/255, blue: 34/255, alpha: 0.1)
let flatRed = UIColor.init(red: 231/255, green: 76/255, blue: 60/255, alpha: 0.1)
