import Foundation

final class TestViewModel: ObservableObject {
    @Published private(set) var currentQuestion: Question?
    @Published private(set) var progress: Double = 0
    @Published private(set) var isFinished: Bool = false
    @Published private(set) var answers: [UserAnswer] = []
    @Published private(set) var selectedOptionForCurrentQuestion: QuestionOption?

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

    /// 선택지를 고름. 마지막 질문이 아니면 자동으로 다음 질문 이동.
    /// 마지막 질문이면 선택 상태만 저장하고 이동은 showResult()가 처리.
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

    /// 결과보기 버튼을 눌렀을 때 호출 (마지막 질문에서만 사용)
    func showResult() {
        guard isLastQuestion, selectedOptionForCurrentQuestion != nil else { return }
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
        updateProgress()
    }

    private func goToNextQuestion() {
        currentIndex += 1
        currentQuestion = questions[currentIndex]
        // 다음 질문에 이미 답한 기록이 있으면 선택 상태 복원 (뒤로가기 대응)
        selectedOptionForCurrentQuestion = answers.first { $0.questionId == currentQuestion?.id }?.selectedOption
        updateProgress()
    }

    private func updateProgress() {
        progress = questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count)
    }

    func resultGroupedByCategory() -> [QuestionCategory: [UserAnswer]] {
        Dictionary(grouping: answers, by: { $0.category })
    }
}
