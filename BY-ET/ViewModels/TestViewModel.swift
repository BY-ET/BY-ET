import Foundation

final class TestViewModel: ObservableObject {
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var progress: Double = 0
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var answers: [UserAnswer] = []
    @Published private(set) var selectedOptionForCurrentQuestion: QuestionOption?
    @Published private(set) var catType: CatType?
    @Published private(set) var categoryJudgements: [CategoryJudgement] = []

    private let questions: [Question]
    private var currentIndex: Int = 0

    init(questions: [Question] = QuestionRepository.questions) {
        self.questions = questions.sorted { $0.order < $1.order }
        self.currentQuestion = self.questions.first
        updateProgress()
    }

    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }
    var canGoBack: Bool {
        currentIndex > 0
    }
    func selectOption(_ option: QuestionOption) {
        guard let question = currentQuestion else { return }

        answers.removeAll { $0.questionId == question.id }
        answers.append(
            UserAnswer(questionId: question.id, category: question.category, selectedOption: option)
        )
        selectedOptionForCurrentQuestion = option

        if !isLastQuestion {
            goToNextQuestion()
        }
    }

    func showResult() {
            guard isLastQuestion, selectedOptionForCurrentQuestion != nil else { return }
            let result = SurveyResultCalculator.calculate(from: answers)
            catType = result.catType
            categoryJudgements = result.judgements

            currentQuestion = nil
            isFinished = true
            updateProgress()
        }


    func goToPreviousQuestion() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        currentQuestion = questions[currentIndex]
        isFinished = false
        selectedOptionForCurrentQuestion = answers.first { $0.questionId == questions[currentIndex].id }?.selectedOption
        updateProgress()
    }

        func restart() {
                currentIndex = 0
                currentQuestion = questions.first
                isFinished = false
                answers = []
                selectedOptionForCurrentQuestion = nil
                catType = nil
                categoryJudgements = []
                updateProgress()
            }
    
    private func goToNextQuestion() {
        currentIndex += 1
        if currentIndex < questions.count {
            currentQuestion = questions[currentIndex]
            selectedOptionForCurrentQuestion = answers.first { $0.questionId == currentQuestion?.id }?.selectedOption
        } else {
            currentQuestion = nil
            isFinished = true
        }
        updateProgress()
    }

    private func updateProgress() {
        guard !questions.isEmpty else {
            progress = 0
            return
        }
        progress = min(Double(currentIndex + 1) / Double(questions.count), 1.0)
    }

    func resultGroupedByCategory() -> [QuestionCategory: [UserAnswer]] {
        Dictionary(grouping: answers, by: { $0.category })
    }
}
