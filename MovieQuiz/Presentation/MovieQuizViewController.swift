import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - QuestionFactoryDelegate
    private var statisticService = StatisticServiceImplementation()
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        
        questionFactory.requestNextQuestion()
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
    }
    
    @IBAction func noButton(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction func yesButton(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterDelegate?
    private var currentQuestion: QuizQuestion?
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        

        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = statisticService.totalAccuracy
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                             Ваш результат: \(correctAnswers)/\(questionsAmount)
                             Количество сыгранных квизов: \(gamesCount)
                             Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                             Средняя точность: \(String(format: "%.2f", totalAccuracy))%
                             """,
                buttonText: "Сыграть еще раз?",
                completion: { [weak self] in
                    guard let self = self else { return }
                    
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.imageView.layer.borderWidth = 0
                    self.imageView.layer.borderColor = nil
                    
                    self.questionFactory?.requestNextQuestion()
                    
                })
            alertPresenter?.show(model: alertModel)
            
        } else {
            currentQuestionIndex += 1
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = nil
            
            questionFactory?.requestNextQuestion()
        }
    }
}
