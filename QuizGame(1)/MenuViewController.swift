//
//  ViewController.swift
//  QuizGame(1)
//
//  Created by Ross on 06/11/2017.
//  Copyright © 2017 Ross. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

class MenuViewController: UIViewController {
    
    
    fileprivate static let padding = 8
    
    private let contentView = UIView(frame: .zero)
    private let logoView = UIImageView(frame: .zero)
    private let buttonView = UIView(frame: .zero)
    private var gameButtons = [RoundedButton]()
    private let scoreView = UIView(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let recentScoreLabel = UILabel(frame: .zero)
    private let highScoreLabel = UILabel(frame: .zero)
    
    private let titles = [
        "Multiple Choice",
        "Image Quiz",
        "Right or Wrong",
        "Emoji Riddle"
    ]
    
    private var recentScores = [Int]()
    private var highScores = [Int]()
    private var scoreIndex = 0
    private var timer = Timer()
    private var adjustedWidthConstraints: (center: Constraint?, left: Constraint?, right: Constraint?)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = UIColor.gray
        view.backgroundColor = UIColor.init(red:41/255.0, green:128/255.0, blue:185/255.0, alpha: 1.0)
        setupViews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    func updateScore() {
        
        recentScores = [
            UserDefaults.standard.integer(forKey: multipleChoiceRecentScoreIdentifier),
            UserDefaults.standard.integer(forKey: imageQuizRecentScoreIdentifier),
            UserDefaults.standard.integer(forKey: rightWrongRecentScoreIdentifier),
            UserDefaults.standard.integer(forKey: emojiRecentScoreIdentifier)
        ]
        
        highScores = [
            UserDefaults.standard.integer(forKey: multipleChoiceHighScoreIdentifier),
            UserDefaults.standard.integer(forKey: imageQuizHighScoreIdentifier),
            UserDefaults.standard.integer(forKey: rightWrongHighScoreIdentifier),
            UserDefaults.standard.integer(forKey: emojiHighScoreIdentifier)
        ]
    }
    
    func setupViews() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        logoView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        recentScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.view.addSubview(contentView)
        self.contentView.addSubview(scoreView)
        self.scoreView.addSubview(titleLabel)
        self.scoreView.addSubview(recentScoreLabel)
        self.scoreView.addSubview(highScoreLabel)
        self.contentView.addSubview(logoView)
        self.logoView.image = UIImage(named: "dog.png")
        self.contentView.addSubview(buttonView)
        
        for (index, title) in titles.enumerated() {
            let button = RoundedButton()
            self.buttonView.addSubview(button)
            
            button.backgroundColor = UIColor.init(red:52/255.0, green:152/255.0, blue:219/255.0, alpha: 1.0)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonHandler), for: .touchUpInside)
            button.tag = index
            gameButtons.append(button)
            
        }
        
        self.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)//.offset(MenuViewController.padding)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.logoView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(MenuViewController.padding * 2)
            make.width.equalTo(contentView).multipliedBy(0.6)
            make.height.equalTo(contentView).multipliedBy(0.2)
        }
        
        self.logoView.contentMode = UIViewContentMode.scaleAspectFit
        
        self.buttonView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView)
            make.top.equalTo(logoView.snp.bottom).offset(MenuViewController.padding * 2)
            make.width.equalTo(contentView).multipliedBy(0.6)
            make.bottom.equalTo(scoreView.snp.top).offset(-MenuViewController.padding)
        }
        
        self.gameButtons[0].snp.makeConstraints { (make) in
            make.top.equalTo(buttonView).offset(-MenuViewController.padding)
            make.leading.equalTo(buttonView)
            make.trailing.equalTo(buttonView)
            make.bottom.equalTo(gameButtons[1].snp.top).offset(-MenuViewController.padding)
            make.height.equalTo(gameButtons[1].snp.height)
        }
        
        self.gameButtons[1].snp.makeConstraints { (make) in
            make.leading.equalTo(buttonView)
            make.trailing.equalTo(buttonView)
            make.bottom.equalTo(gameButtons[2].snp.top).offset(-MenuViewController.padding)
            make.height.equalTo(gameButtons[2].snp.height)
        }
        
        self.gameButtons[2].snp.makeConstraints { (make) in
            make.leading.equalTo(buttonView)
            make.trailing.equalTo(buttonView)
            make.bottom.equalTo(gameButtons[3].snp.top).offset(-MenuViewController.padding)
            make.height.equalTo(gameButtons[3].snp.height)
        }
        
        self.gameButtons[3].snp.makeConstraints { (make) in
            make.leading.equalTo(buttonView)
            make.trailing.equalTo(buttonView)
            make.bottom.equalTo(buttonView).offset(-MenuViewController.padding)
        }
        
        self.scoreView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView).priority(250)
            make.width.equalTo(contentView).multipliedBy(0.6)
            make.height.equalTo(contentView).multipliedBy(0.3)
            make.bottom.equalTo(contentView).offset(-30)
            
            self.adjustedWidthConstraints.center = make.centerY.equalTo(contentView).constraint.update(priority: 800)
            self.adjustedWidthConstraints.left = make.trailing.equalTo(contentView.snp.leading).constraint.update(priority: 800)
            self.adjustedWidthConstraints.right = make.leading.equalTo(contentView.snp.trailing).constraint.update(priority: 800)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(scoreView)
            make.leading.equalTo(scoreView)
            make.trailing.equalTo(scoreView)
            make.height.equalTo(recentScoreLabel)
            make.bottom.equalTo(recentScoreLabel.snp.top).offset(-MenuViewController.padding)
        }
        
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.textColor = UIColor.white
        titleLabel.text = titles[scoreIndex]
        
        self.recentScoreLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(scoreView)
            make.trailing.equalTo(scoreView)
            make.bottom.equalTo(highScoreLabel.snp.top).offset(-MenuViewController.padding)
            make.height.equalTo(highScoreLabel)
        }
        
        recentScoreLabel.textAlignment = .left
        recentScoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        recentScoreLabel.textColor = UIColor.white
        recentScoreLabel.text = "Recent: " + String(UserDefaults.standard.integer(forKey: multipleChoiceRecentScoreIdentifier))
        
        self.highScoreLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(scoreView)
            make.trailing.equalTo(scoreView)
            make.height.equalTo(recentScoreLabel.snp.height)
            make.bottom.equalTo(scoreView.snp.bottom).offset(-MenuViewController.padding)
        }
        
        highScoreLabel.textAlignment = .left
        highScoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        highScoreLabel.textColor = UIColor.white
        highScoreLabel.text = "High Score: " + String(UserDefaults.standard.integer(forKey: multipleChoiceHighScoreIdentifier))
        
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(nextScores), userInfo: nil, repeats: true)
        
    }
    
    func buttonHandler(sender: RoundedButton) {
        var vc: UIViewController?
        switch sender.tag {
        case 0:
            //Multiple Choice
            vc = MultipleChoiceViewController()
        case 1:
            vc = ImageQuizViewController()
        case 2:
            vc = RightWrongQuizViewController()
        case 3:
            vc = EmojiQuizViewController()
        default:
            break
        }
        if let newVC = vc {
            navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    func nextScores() {
        scoreIndex = scoreIndex < (recentScores.count - 1) ? scoreIndex + 1 : 0
        
        UIView.animate(withDuration: 1.5, animations: {
            self.adjustedWidthConstraints.center?.deactivate()
            self.adjustedWidthConstraints.left?.activate()
            self.view.layoutIfNeeded()
            
        }) { (completion: Bool) in
            
            self.titleLabel.text = self.titles[self.scoreIndex]
            
            if self.recentScores.count > 0 {
                self.recentScoreLabel.text  = "Recent: " + String(self.recentScores[self.scoreIndex])
            }
            
            if self.highScores.count > 0 {
                self.highScoreLabel.text = "Highscore: " + String(self.highScores[self.scoreIndex])
            }
            
            self.adjustedWidthConstraints.left?.deactivate()
            self.adjustedWidthConstraints.right?.activate()
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 1.5, animations: {
                self.adjustedWidthConstraints.right?.deactivate()
                self.adjustedWidthConstraints.center?.activate()
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
}



