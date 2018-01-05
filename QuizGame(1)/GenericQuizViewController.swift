import Foundation
import UIKit
import SnapKit

class GenericQuizViewController: UIViewController {
    
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

    // Change Colours for different quiz
    
    private let backgroundColor = UIColor.init(red:44/255.0, green:62/255.0, blue:80/255.0, alpha: 1.0)
    private let foregroundColor = UIColor.init(red: 52/255.0, green:73/255.0, blue:94/255.0, alpha: 1.0)
    
    private let quizLoader = QuizLoader()
    
    //Select according question type
    
    private var questionArray = [MultipleChoiceQuestion]()
    private var questionIndex = 0
    //
    private var currentQuestion: MultipleChoiceQuestion!
    
    private var timer = Timer()
    private var score = 0
    
    //Change Identifier
    
    private var highScore = UserDefaults.standard.integer(forKey: multipleChoiceHighScoreIdentifier)
    
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
            make.top.equalTo(contentView).offset(GenericQuizViewController.padding)
            make.leading.equalTo(contentView).offset(GenericQuizViewController.padding)
            make.trailing.equalTo(contentView).offset(-GenericQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(answerView)
        self.answerView.snp.makeConstraints { (make) in
            make.top.equalTo(questionView.snp.bottom).offset(GenericQuizViewController.padding)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView).offset(GenericQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(countdownView)
        self.countdownView.snp.makeConstraints{ (make) in
            make.top.equalTo(answerView.snp.bottom).offset(GenericQuizViewController.padding)
            make.leading.equalTo(contentView).offset(GenericQuizViewController.padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-GenericQuizViewController.padding)
            make.bottom.equalTo(contentView).offset(GenericQuizViewController.padding)
        }
        
        self.countdownView.addSubview(progressView)
        self.progressView.snp.makeConstraints{ (make) in
            make.centerY.equalTo(countdownView)
            make.leading.equalTo(countdownView)
            make.trailing.equalTo(countdownView)
        }
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 10)
        
        loadQuestions()
    }
    
    func loadQuestions() {
        do {
            //Load appropriate questions
            questionArray = try quizLoader.loadMultipleChoiceQuiz(forQuiz: "MultipleChoice")
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
    
    
    func answerButtonHandler(_ sender: RoundedButton) {
        timer.invalidate()
        if sender.titleLabel?.text == currentQuestion.correctAnswer {
            score += 1
            questionLabel.text = "Tap to continue"
            questionButton.isEnabled = true
        } else {
            sender.backgroundColor = UIColor.red
            showAlert(forReason: 1)
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
        // hange Userdefault keys
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: multipleChoiceHighScoreIdentifier)
        }
        UserDefaults.standard.set(score, forKey: multipleChoiceRecentScoreIdentifier)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            timer.invalidate()
        }
    }
}


