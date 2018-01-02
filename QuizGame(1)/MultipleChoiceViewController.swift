import Foundation
import UIKit
import SnapKit

class MultipleChoiceViewController: UIViewController {
    
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

    
    private let backgroundColor = UIColor.init(red:44/255.0, green:62/255.0, blue:80/255.0, alpha: 1.0)
    private let foregroundColor = UIColor.init(red: 52/255.0, green:73/255.0, blue:94/255.0, alpha: 1.0)
    
    private let quizLoader = QuizLoader()
    private var questionArray = [MultipleChoiceQuestion]()
    private var questionIndex = 0
    private var currentQuestion: MultipleChoiceQuestion!
    
    private var timer = Timer()
    private var score = 0
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
        contentView.translatesAutoresizingMaskIntoConstraints = false
        questionView.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionButton.translatesAutoresizingMaskIntoConstraints = false
        answerView.translatesAutoresizingMaskIntoConstraints = false
        countdownView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
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
            make.top.equalTo(contentView).offset(MultipleChoiceViewController.padding)
            make.leading.equalTo(contentView).offset(MultipleChoiceViewController.padding)
            make.trailing.equalTo(contentView).offset(-MultipleChoiceViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        self.questionView.addSubview(questionLabel)
        self.questionLabel.snp.makeConstraints { (make) in
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
        self.questionButton.snp.makeConstraints { (make) in
            make.top.equalTo(questionView)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView)
            make.bottom.equalTo(questionView)
        }
        
        questionButton.isEnabled = false
        questionButton.addTarget(self, action: #selector(questionButtonHandler), for: .touchUpInside)

        
        self.contentView.addSubview(answerView)
        self.answerView.snp.makeConstraints { (make) in
            make.top.equalTo(questionView.snp.bottom).offset(MultipleChoiceViewController.padding)
            make.leading.equalTo(questionView)
            make.trailing.equalTo(questionView).offset(MultipleChoiceViewController.padding)
            make.height.equalTo(contentView).multipliedBy(0.4)
        }
        
        var answersButtonsConstraints = [
        
        self.answerButtons[0].snp.makeConstraints { (make) in
            make.leading.equalTo(answerView)
            make.trailing.equalTo(answerButtons[1].snp.leading).offset(-MultipleChoiceViewController.buttonPadding)
            make.top.equalTo(answerView)
            make.bottom.equalTo(answerButtons[2].snp.top).offset(-MultipleChoiceViewController.buttonPadding)
        },
        
        self.answerButtons[1].snp.makeConstraints { (make) in
            make.trailing.equalTo(answerView).offset(-MultipleChoiceViewController.padding)
            make.top.equalTo(answerView)
            make.bottom.equalTo(answerButtons[3]).offset(MultipleChoiceViewController.buttonPadding)
        },
        
        self.answerButtons[2].snp.makeConstraints { (make) in
            make.leading.equalTo(answerView)
            make.trailing.equalTo(answerButtons[3].snp.leading).offset(-MultipleChoiceViewController.buttonPadding)
            make.bottom.equalTo(answerView)
        },
        
        self.answerButtons[3].snp.makeConstraints { (make) in
            make.trailing.equalTo(answerView).offset(-MultipleChoiceViewController.padding)
            make.bottom.equalTo(answerView)
        }]
        
        for index in 1..<answerButtons.count {
            let constraint : () = self.answerButtons[index].snp.makeConstraints { (make) in
                make.height.equalTo(answerButtons[index-1].snp.height)
                make.width.equalTo(answerButtons[index-1].snp.width)
            }
            answersButtonsConstraints.append(constraint)
        }
        
        self.contentView.addSubview(countdownView)
        self.countdownView.snp.makeConstraints{ (make) in
            make.top.equalTo(answerView.snp.bottom).offset(MultipleChoiceViewController.padding)
            make.leading.equalTo(contentView).offset(MultipleChoiceViewController.padding)
            make.trailing.equalTo(contentView.snp.trailing).offset(-MultipleChoiceViewController.padding)
            make.bottom.equalTo(contentView).offset(MultipleChoiceViewController.padding)
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
        for (index,button) in answerButtons.enumerated() {
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.setTitle(currentQuestion.answers[index], for: .normal)
            button.isEnabled = true
            button.backgroundColor = foregroundColor
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
        for button in answerButtons {
            button.isEnabled = false
        }
    }
    
    func  questionButtonHandler() {
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
            sender.backgroundColor = UIColor.red
            showAlert(forReason: 1)
        }
        for button in answerButtons {
            button.isEnabled = false
            if button.titleLabel?.text == currentQuestion.correctAnswer {
                button.backgroundColor = flatGreen
            } else {
                button.backgroundColor = flatRed
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

