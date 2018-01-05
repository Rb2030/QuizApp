import Foundation
import UIKit
import SnapKit

class EmojiQuizViewController: UIViewController, UITextFieldDelegate {
    
    private static let padding = 20
    private static let buttonPadding = 8
    
    private let contentView = UIView()
    private let questionView = UIView()
    private let answerView = UIView()
    private let answerTextField = UITextField()
    private let countdownView = UIView()
    private let questionLabel = RoundedLabel()
    private let questionButton = RoundedButton()
    private var answerButtons = [RoundedButton]()
    private let progressView = UIProgressView()

    
    private let backgroundColor = UIColor.init(red:41/255.0, green:128/255.0, blue:185/255.0, alpha: 1.0)
    private let foregroundColor = UIColor.init(red: 52/255.0, green:152/255.0, blue:219/255.0, alpha: 1.0)
    
    private let quizLoader = QuizLoader()
    
    private var questionArray = [SimpleQuestion]()
    private var questionIndex = 0
    private var currentQuestion: SimpleQuestion!
    
    private var timer = Timer()
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: emojiHighScoreIdentifier)
    
    private var quizAlertView: QuizAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)

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
            make.top.equalTo(contentView).offset(EmojiQuizViewController.padding)
            make.leading.equalTo(contentView).offset(EmojiQuizViewController.padding)
            make.trailing.equalTo(contentView).offset(-EmojiQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(answerView)
        self.answerView.snp.makeConstraints { (make) in
            make.top.equalTo(questionView.snp.bottom).offset(EmojiQuizViewController.padding)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView).offset(EmojiQuizViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.contentView.addSubview(countdownView)
        self.countdownView.snp.makeConstraints{ (make) in
            make.top.equalTo(answerView.snp.bottom).offset(EmojiQuizViewController.padding)
            make.leading.equalTo(contentView).offset(EmojiQuizViewController.padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-EmojiQuizViewController.padding)
            make.bottom.equalTo(contentView).offset(EmojiQuizViewController.padding)
        }
        
        self.countdownView.addSubview(progressView)
        self.progressView.snp.makeConstraints{ (make) in
            make.centerY.equalTo(countdownView)
            make.leading.equalTo(countdownView)
            make.trailing.equalTo(countdownView)
        }
        
        self.answerView.addSubview(answerTextField)
        self.answerTextField.snp.makeConstraints{ (make) in
            make.centerY.equalTo(answerView)
            make.centerX.equalTo(answerView)
            make.height.equalTo(answerView).multipliedBy(0.5)
            make.leading.equalTo(answerView)
            make.trailing.equalTo(answerView)
        }
        
        answerTextField.textColor = UIColor.white
        answerTextField.textAlignment = .center
        answerTextField.font = UIFont.boldSystemFont(ofSize: 30.0)
        answerTextField.adjustsFontSizeToFitWidth = true
        answerTextField.autocorrectionType = .no
        answerTextField.isEnabled = false
        answerTextField.delegate = self
        
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
        
        self.questionButton.addTarget(self, action: #selector(questionButtonHandler), for: .touchUpInside)
        questionButton.isEnabled = false
        
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 10)
        
        loadQuestions()
    }
    
    func loadQuestions() {
        do {
            questionArray = try quizLoader.loadSimpleQuiz(forQuiz: "EmojiQuiz")
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
        questionLabel.backgroundColor = foregroundColor
        questionLabel.text = currentQuestion.question
        answerTextField.text = nil
        answerTextField.placeholder = "Answer"
        answerTextField.isEnabled = true
        startTimer()
    }
    
    func startTimer() {
        progressView.progressTintColor = UIColor.green
        progressView.trackTintColor = UIColor.clear
        progressView.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
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
    
    func checkAnswer(withString string: String) {
        timer.invalidate()
        answerTextField.isEnabled = false
        if string == currentQuestion.correctAnswer {
            questionLabel.backgroundColor = flatGreen
            questionButton.isEnabled = true
            score += 1
        } else {
            questionLabel.backgroundColor = flatRed
            showAlert(forReason: 1)
        }
        questionLabel.text = currentQuestion.correctAnswer
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let string = textField.text?.uppercased() {
            checkAnswer(withString: string)
        }
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.answerView.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.answerView.frame.origin.y += keyboardSize.height
        }
    }
    
    func showAlert(forReason reason: Int) {
        
        switch reason {
        
        case 0:
            quizAlertView = QuizAlertView(withTitle: "You Lost", andMessage: "You ran out of time!", colors: [backgroundColor, foregroundColor])
        
        case 1:
            quizAlertView = QuizAlertView(withTitle: "You Lost", andMessage: "You entered the wrong answer!", colors: [backgroundColor, foregroundColor])
            
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

        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: emojiHighScoreIdentifier)
        }
        UserDefaults.standard.set(score, forKey: emojiRecentScoreIdentifier)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            timer.invalidate()
        }
    }
}


