//
//  RoundedButton.swift
//  QuizGame(1)
//
//  Created by Ross on 06/11/2017.
//  Copyright © 2017 Ross. All rights reserved.
//

import UIKit
import SnapKit

    
    class RoundedButton: UIButton {
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            layer.cornerRadius = 5.0
            layer.masksToBounds = true
        }
        
}
