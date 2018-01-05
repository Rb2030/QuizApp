import Foundation
import UIKit
import SnapKit

class RightWrongQuizViewController: UIViewController {
    
    private static let padding = 20
    private static let buttonPadding = 8
    
    private let contentView = UIView()
    private let questionView = UIView()
    private let answerView = UIView()
    private let countdownView = UIView()
    private let questionLabel = RoundedLabel()
    private let questionButton = RoundedButton()
    private var answerButtons = [RoundedButton]()
    private let progressView = UIProgressView()
    
    
    private let backgroundColor = UIColor.init(red:189/255.0, green:195/255.0, blue:199/255.0, alpha: 1.0)
    private let foregroundColor = UIColor.init(red: 236/255.0, green:240/255.0, blue:241/255.0, alpha: 1.0)
    
    private let quizLoader = QuizLoader()
    private var questionArray = [SimpleQuestion]()
    private var questionIndex = 0
    private var currentQuestion: SimpleQuestion!
    
    private var timer = Timer()
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: rightWrongHighScoreIdentifier)
    
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
        
        view.addSubview(contentView)
        self.contentView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        self.contentView.addSubview(questionView)
        self.questionView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView).offset(RightWrongQuizViewController.padding)
            make.leading.equalTo(contentView).offset(RightWrongQuizViewController.padding)
            make.trailing.equalTo(contentView).offset(-RightWrongQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(answerView)
        self.answerView.snp.makeConstraints { (make) in
            make.top.equalTo(questionView.snp.bottom).offset(RightWrongQuizViewController.padding)
            make.leading.equalTo(contentView).offset(RightWrongQuizViewController.padding)
            make.trailing.equalTo(contentView).offset(-RightWrongQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(countdownView)
        self.countdownView.snp.makeConstraints{ (make) in
            make.top.equalTo(answerView.snp.bottom).offset(RightWrongQuizViewController.padding)
            make.leading.equalTo(contentView).offset(RightWrongQuizViewController.padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-RightWrongQuizViewController.padding)
            make.bottom.equalTo(contentView).offset(-RightWrongQuizViewController.padding)
        }
        
        self.countdownView.addSubview(progressView)
        self.progressView.snp.makeConstraints{ (make) in
            make.leading.equalTo(countdownView)
            make.trailing.equalTo(countdownView)
            make.centerY.equalTo(countdownView)
        }
        
        self.questionView.addSubview(questionLabel)
        self.questionLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(questionView)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView)
            make.bottom.equalTo(questionView)
        }
        
        questionLabel.backgroundColor = foregroundColor
        questionLabel.textColor = UIColor.white
        questionLabel.font = UIFont.boldSystemFont(ofSize: 30)
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 4
        questionLabel.adjustsFontSizeToFitWidth = true
        
        self.questionView.addSubview(questionButton)
        self.questionButton.snp.makeConstraints{ (make) in
            make.top.equalTo(questionView)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView)
            make.bottom.equalTo(questionView)
        }
        
        for index in 0...1 {
            let button = RoundedButton()
            answerButtons.append(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            answerView.addSubview(button)
            index == 0 ? button.setTitle("Correct", for: .normal) : button.setTitle("Wrong", for: .normal)
            button.addTarget(self, action: #selector(answerButtonHandler), for: .touchUpInside)
        }
        
        var answerButtonsConstraints = [
            
            self.answerButtons[0].snp.makeConstraints { (make) in
                make.leading.equalTo(answerView)
                make.trailing.equalTo(answerView)
                make.top.equalTo(answerView)
                make.bottom.equalTo(answerButtons[1].snp.top).offset(-RightWrongQuizViewController.buttonPadding)
                make.height.equalTo(answerButtons[1])
                make.width.equalTo(answerButtons[1])
            },
            
            self.answerButtons[1].snp.makeConstraints { (make) in
                make.leading.equalTo(answerView)
                make.trailing.equalTo(answerView)
                make.bottom.equalTo(answerView)
                
            }
        ]
        
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 10)
        
        loadQuestions()
    }
    
    func loadQuestions() {
        do {
            questionArray = try quizLoader.loadSimpleQuiz(forQuiz: "RightWrongQuiz")
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
        currentQuestion = questionArray[questionIndex]
        setTitlesForButtons()
    }
    
    func setTitlesForButtons() {
        for button in answerButtons {
            button.isEnabled = true
            button.backgroundColor = foregroundColor
            button.setTitleColor(UIColor.darkGray, for: .normal)
        }
        questionLabel.text = currentQuestion.question
        startTimer()
    }
    
    func startTimer() {
        progressView.progressTintColor = UIColor.green
        progressView.trackTintColor = UIColor.clear
        progressView.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
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
    }
    
    func questionButtonHandler() {
        questionButton.isEnabled = false
        questionIndex += 1
        questionIndex < questionArray.count ? loadNextQuestion() : showAlert(forReason: 2)
    }
    
    func answerButtonHandler(_ sender: RoundedButton) {
        timer.invalidate()
        if sender.titleLabel?.text == currentQuestion.correctAnswer {
            score += 1
            questionLabel.text = "Tap to continue"
            questionButton.isEnabled = true
        } else {
            sender.backgroundColor = flatRed
            sender.setTitleColor(UIColor.white, for: .normal)
            showAlert(forReason: 1)
        }
        for button in answerButtons {
            button.isEnabled = false
            if button.titleLabel?.text == currentQuestion.correctAnswer {
                button.backgroundColor = flatGreen
                button.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }
    
    func showAlert(forReason reason: Int) {
        switch reason {
            
        case 0:
            quizAlertView = QuizAlertView(withTitle: "You Lost", andMessage: "You ran out of time!", colors: [backgroundColor, foregroundColor])
            
        case 1:
            quizAlertView = QuizAlertView(withTitle: "You Lost", andMessage: "You picked the wrong answer!", colors: [backgroundColor, foregroundColor])
            
        case 2:
            quizAlertView = QuizAlertView(withTitle: "You won", andMessage: "You answered all the questions correctly!", colors: [backgroundColor, foregroundColor])
            
        default:
            break
        }
        
        if let qav = quizAlertView {
            
            quizAlertView?.closeButton.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
            quizAlertView?.closeButton.setTitleColor(UIColor.darkGray, for: .normal)
            createQuizAlertView(withAlert: qav)
            
        }
    }
    
    func createQuizAlertView(withAlert alert: QuizAlertView) {
        
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
            UserDefaults.standard.set(highScore, forKey: rightWrongHighScoreIdentifier)
        }
        UserDefaults.standard.set(score, forKey: rightWrongHighScoreIdentifier)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            timer.invalidate()
        }
    }
}
