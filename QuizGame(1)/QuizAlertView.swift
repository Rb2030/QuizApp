//
//  QuizAlertView.swift
//  QuizGame(1)
//
//  Created by Ross on 30/11/2017.
//  Copyright © 2017 Ross. All rights reserved.
//

import UIKit

class QuizAlertView: UIView {

    
    private static let padding = 10
    
    private let alertView = UIView()
    private let titleLabel = RoundedLabel()
    private let messageLabel = RoundedLabel()
    let closeButton = UIButton()
    
    init(withTitle title: String, andMessage message: String, colors: [UIColor]) {
        super.init(frame: CGRect.zero)
        titleLabel.text = title
        messageLabel.text = message
        alertView.backgroundColor = colors[0]
        closeButton.backgroundColor = colors[1]
        setupViews()
    }
    
    func setupViews() {
        
        self.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.85)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(alertView)
        
        alertView.addSubview(titleLabel)
        
        alertView.addSubview(messageLabel)
        
        alertView.addSubview(closeButton)
        
        
        let alertViewConstraints = [
        
        self.alertView.snp.makeConstraints{ (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
            make.height.equalTo(self).multipliedBy(0.3)
            make.width.equalTo(self).multipliedBy(0.8)
        
        },
        
        self.titleLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(alertView).offset(QuizAlertView.padding)
            make.leading.equalTo(alertView)
            make.trailing.equalTo(alertView)
            make.height.equalTo(alertView).multipliedBy(0.2)
        },
        
        self.messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalTo(alertView)
            make.trailing.equalTo(alertView)
            make.bottom.equalTo(closeButton.snp.top)
        },
        
        self.closeButton.snp.makeConstraints { (make) in
            make.height.equalTo(alertView).multipliedBy(0.2)
            make.leading.equalTo(alertView)
            make.trailing.equalTo(alertView)
            make.bottom.equalTo(alertView)
        }]
        
        
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.textAlignment = .center
        
        self.messageLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.messageLabel.numberOfLines = 2
        self.messageLabel.adjustsFontSizeToFitWidth = true
        self.messageLabel.textColor = UIColor.white
        self.messageLabel.textAlignment = .center
        
        self.closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        self.closeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.closeButton.titleLabel?.textColor = UIColor.white
        self.closeButton.setTitle("Continue", for: .normal)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
