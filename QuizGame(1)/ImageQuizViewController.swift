import Foundation
import UIKit
import SnapKit

class ImageQuizViewController: UIViewController {
    
    private static let padding = 20
    private static let buttonPadding = 8
    
    private let contentView = UIView()
    private let questionView = UIImageView()
    private let answerView = UIView()
    private let countdownView = UIView()
    private var answerButtons = [RoundedButton]()
    private let progressView = UIProgressView()
    private var imageGridViews = [UIView]()
    
    
    private let backgroundColor = UIColor.init(red:51/255.0, green:110/255.0, blue:123/255.0, alpha: 1.0)
    private let foregroundColor = UIColor.init(red: 197/255.0, green:239/255.0, blue:247/255.0, alpha: 1.0)
    
    private let quizLoader = QuizLoader()
    
    private var questionArray = [MultipleChoiceQuestion]()
    private var questionIndex = 0
    
    private var currentQuestion: MultipleChoiceQuestion!
    
    private var timer = Timer()
    private var revealTimer = Timer()
    private var revealIndex = 0
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: imageQuizHighScoreIdentifier)
    
    private var quizAlertView: QuizAlertView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupViews() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        questionView.translatesAutoresizingMaskIntoConstraints = false
        answerView.translatesAutoresizingMaskIntoConstraints = false
        countdownView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 0...8 {
            let view = UIView()
            imageGridViews.append(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            questionView.addSubview(view)
            view.backgroundColor = foregroundColor
            
        }
        
        for _ in 0...3 {
            let button = RoundedButton()
            answerButtons.append(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            answerView.addSubview(button)
            button.addTarget(self, action: #selector(answerButtonHandler), for: .touchUpInside)
            
        }

        
        view.addSubview(contentView)
        self.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        self.contentView.addSubview(questionView)
        self.questionView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(ImageQuizViewController.padding)
            make.leading.equalTo(contentView).offset(ImageQuizViewController.padding)
            make.trailing.equalTo(contentView).offset(-ImageQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(answerView)
        self.answerView.snp.makeConstraints { (make) in
            make.top.equalTo(questionView.snp.bottom).offset(ImageQuizViewController.padding)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView).offset(ImageQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(countdownView)
        self.countdownView.snp.makeConstraints{ (make) in
            make.top.equalTo(answerView.snp.bottom).offset(ImageQuizViewController.padding)
            make.leading.equalTo(contentView).offset(ImageQuizViewController.padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-ImageQuizViewController.padding)
            make.bottom.equalTo(contentView).offset(ImageQuizViewController.padding)
        }
        
        self.countdownView.addSubview(progressView)
        self.progressView.snp.makeConstraints{ (make) in
            make.centerY.equalTo(countdownView)
            make.leading.equalTo(countdownView)
            make.trailing.equalTo(countdownView)
        }
        
        var answersButtonsConstraints = [
            
            self.answerButtons[0].snp.makeConstraints { (make) in
                make.leading.equalTo(answerView)
                make.trailing.equalTo(answerButtons[1].snp.leading).offset(-ImageQuizViewController.buttonPadding)
                make.top.equalTo(answerView)
                make.bottom.equalTo(answerButtons[2].snp.top).offset(-ImageQuizViewController.buttonPadding)
            },
            
            self.answerButtons[1].snp.makeConstraints { (make) in
                make.trailing.equalTo(answerView).offset(-ImageQuizViewController.padding)
                make.top.equalTo(answerView)
                make.bottom.equalTo(answerButtons[3]).offset(ImageQuizViewController.buttonPadding)
            },
            
            self.answerButtons[2].snp.makeConstraints { (make) in
                make.leading.equalTo(answerView)
                make.trailing.equalTo(answerButtons[3].snp.leading).offset(-ImageQuizViewController.buttonPadding)
                make.bottom.equalTo(answerView)
            },
            
            self.answerButtons[3].snp.makeConstraints { (make) in
                make.trailing.equalTo(answerView).offset(-ImageQuizViewController.padding)
                make.bottom.equalTo(answerView)
            }]
        
        for index in 1..<answerButtons.count {
            
            let constraint : () = self.answerButtons[index].snp.makeConstraints { (make) in
                make.height.equalTo(answerButtons[index-1].snp.height)
                make.width.equalTo(answerButtons[index-1].snp.width)
            }
            answersButtonsConstraints.append(constraint)
        }

        progressView.transform = progressView.transform.scaledBy(x: 1, y: 10)
        
        for index in 0..<imageGridViews.count {
            
            if [0,1,2].contains(index) {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.top.equalTo(questionView)
                }
            }
            
            if [3,4,5].contains(index) {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.top.equalTo(imageGridViews[0].snp.bottom)
                }
            }
            
            if [6,7,8].contains(index) {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.top.equalTo(imageGridViews[3].snp.bottom)
                    make.bottom.equalTo(questionView)
                }
            }
            
            if [0,3,6].contains(index) {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.leading.equalTo(questionView)
                }
            }
            
            if [1,4,7].contains(index) {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.leading.equalTo(imageGridViews[0].snp.trailing)
                }
            }
            if [2,5,8].contains(index) {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.leading.equalTo(imageGridViews[1].snp.trailing)
                    make.trailing.equalTo(questionView)
                }
            }
            
            if index > 0 {
                self.imageGridViews[index].snp.makeConstraints { (make) in
                    make.height.equalTo(imageGridViews[index-1].snp.height)
                    make.width.equalTo(imageGridViews[index-1].snp.width)
                }
            }
        }
        
        loadQuestions()
    }
    
    func loadQuestions() {
        do {
            //Load appropriate questions
            questionArray = try quizLoader.loadMultipleChoiceQuiz(forQuiz: "ImageQuiz")
            loadNextQuestion()
        } catch {
            switch error {
            case LoaderError.dictionaryFailed:
                print("Could not load dictionary")
            case LoaderError.pathFailed:
                print("Could not find valid file at path")
            default:
                print("Unknown error")
            }
        }
    }
    
    func loadNextQuestion() {
        if quizAlertView != nil {
            quizAlertView?.removeFromSuperview()
        }
        currentQuestion = questionArray[questionIndex]
        setTitlesForButtons()
    }
    
    func setTitlesForButtons() {
        for (index, button) in answerButtons.enumerated() {
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.setTitle(currentQuestion.answers[index], for: .normal)
            button.isEnabled = true
            button.backgroundColor = foregroundColor
            button.setTitleColor(UIColor.darkGray, for: .normal)
        }
        
        for view in imageGridViews {
            view.alpha = 1.0
        }
        
        imageGridViews.shuffle()
        questionView.image = UIImage(named: currentQuestion.question)
        revealTile()
        revealIndex = 0
        startTimer()
    }
    
    func startTimer() {
        progressView.progressTintColor = UIColor.green
        progressView.trackTintColor = UIColor.clear
        progressView.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
        revealTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(revealTile), userInfo: nil, repeats: true)
    }
    
    func revealTile() {
        if revealIndex < imageGridViews.count {
            UIView.animate(withDuration: 0.12, animations: {
                self.imageGridViews[self.revealIndex].alpha = 0.0
            })
            
            revealIndex += 1
        }
    }
    
    func updateProgressView() {
        progressView.progress -= 0.01/15
        if progressView.progress <= 0 {
            outOfTime()
        } else if progressView.progress <= 0.2 {
            progressView.progressTintColor = flatRed
        } else if progressView.progress <= 0.5 {
            progressView.progressTintColor = flatOrange
        }
    }
    
    func outOfTime() {
        timer.invalidate()
        showAlert(forReason: 0)
        for button in answerButtons {
            button.isEnabled = false
        }
    }
    
    
    func answerButtonHandler(_ sender: RoundedButton) {
        for view in imageGridViews {
            view.alpha = 0.0
        }
        revealTimer.invalidate()
        timer.invalidate()
        if sender.titleLabel?.text == currentQuestion.correctAnswer {
            score += 1 + (imageGridViews.count - revealIndex)
            questionIndex += 1
            questionIndex < questionArray.count ? showAlert(forReason: 3) : showAlert(forReason: 2)
        } else {
            sender.backgroundColor = UIColor.red
            showAlert(forReason: 1)
        }
        for button in answerButtons {
            button.isEnabled = false
            if button.titleLabel?.text == currentQuestion.correctAnswer {
                button.backgroundColor = flatGreen
            }
        }
    }
    
    func showAlert(forReason reason: Int) {
        switch reason {
        
        case 0:
            quizAlertView = QuizAlertView(withTitle: "You Lost", andMessage: "You ran out of time!", colors: [backgroundColor, foregroundColor])
            quizAlertView?.closeButton.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
        
        case 1:
            quizAlertView = QuizAlertView(withTitle: "You Lost", andMessage: "You picked the wrong answer!", colors: [backgroundColor, foregroundColor])
            quizAlertView?.closeButton.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
            
        case 2:
            quizAlertView = QuizAlertView(withTitle: "You won", andMessage: "You answered all the questions correctly!", colors: [backgroundColor, foregroundColor])
            quizAlertView?.closeButton.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
            
        case 3:
            quizAlertView = QuizAlertView(withTitle: "Correct", andMessage: "Tap continue to go to the next question!", colors: [backgroundColor, foregroundColor])
            quizAlertView?.closeButton.addTarget(self, action: #selector(loadNextQuestion), for: .touchUpInside)

        default:
            break
        }
        
        if let qav = quizAlertView {
            quizAlertView?.closeButton.setTitleColor(UIColor.darkGray, for: .normal)
            createQuizAlertView(withAlert: qav)
        
        }
    }
    
    func createQuizAlertView(withAlert alert: QuizAlertView) {
        alert.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    func closeAlert() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: imageQuizHighScoreIdentifier)
        }
        UserDefaults.standard.set(score, forKey: imageQuizRecentScoreIdentifier)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            revealTimer.invalidate()
            timer.invalidate()
        }
    }
}

