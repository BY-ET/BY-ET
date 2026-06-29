import SwiftUI

struct TestView: View {
    @StateObject private var viewModel = TestViewModel()

    var body: some View {
        VStack {
            if let question = viewModel.currentQuestion {
                QuestionPageView(
                    question: question,
                    progress: viewModel.progress,
                    isLastQuestion: viewModel.isLastQuestion,
                    selectedOption: viewModel.selectedOptionForCurrentQuestion,
                    onSelect: { option in
                        withAnimation {
                            viewModel.selectOption(option)
                        }
                    },
                    onShowResult: {
                        withAnimation {
                            viewModel.showResult()
                        }
                    }
                )
            } else if viewModel.isFinished {
                SurveyResultView(viewModel: viewModel)
            }
        }
        .background(Color("P050"))
        .animation(.easeInOut, value: viewModel.currentQuestion?.id)
    }
}

private struct QuestionPageView: View {
    let question: Question
    let progress: Double
    let isLastQuestion: Bool
    let selectedOption: QuestionOption?
    let onSelect: (QuestionOption) -> Void
    let onShowResult: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            CustomProgressBar(progress: progress)
                .padding(.horizontal)
            Spacer()

            Text(question.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 16) {
                ForEach(question.options) { option in
                    Button {
                        onSelect(option)
                    } label: {                        Text(option.text)
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 350, height: 56)
                            .background(selectedOption == option ? Color("P200") : Color("W"))
                            .foregroundColor(.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedOption == option ? Color("P400") : .clear, lineWidth: 2)
                            )
                            .cornerRadius(28)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            if isLastQuestion {
                Button {
                    onShowResult()
                } label: {
                    Text("결과보기")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedOption == nil ? Color("G200") : Color("P400"))
                        .foregroundColor(.white)
                        .cornerRadius(28)
                }
                .disabled(selectedOption == nil)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .padding(.top, 24)
    }
}

private struct SurveyResultView: View {
    @ObservedObject var viewModel: TestViewModel

    var body: some View {
        let grouped = viewModel.resultGroupedByCategory()

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("설문이 끝났어요 🎉")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 32)

                ForEach(QuestionCategory.allCases, id: \.self) { category in
                    if let categoryAnswers = grouped[category] {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.rawValue)
                                .font(.headline)
                                .foregroundColor(.secondary)

                            ForEach(categoryAnswers) { answer in
                                Text("선택: \(answer.selectedOption.text)")
                                    .font(.body)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }

                Button {
                    viewModel.restart()
                } label: {
                    Text("다시하기")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    TestView()
}
