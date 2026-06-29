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
                    canGoBack: viewModel.canGoBack,
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
                    },
                    onBack: {
                        withAnimation {
                            viewModel.goToPreviousQuestion()
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
    let canGoBack: Bool
    let selectedOption: QuestionOption?
    let onSelect: (QuestionOption) -> Void
    let onShowResult: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            HStack {
                if canGoBack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                Spacer()
                Text("유형 탐색")
                Spacer()
            }
            .frame(height: 24)
            .padding(.horizontal)

            CustomProgressBar(progress: progress)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 8) {
                Text("Q\(question.order).")
                    .font(.system(size: 24, weight: .bold))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("P400"))
                
                Text(question.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            VStack(spacing: 16) {
                ForEach(question.options) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        Text(option.text)
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 350, height: 56)
                            .background(selectedOption == option ? Color("P200") : Color("W"))
                            .foregroundColor(.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
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
        ScrollView {
            VStack(spacing: 24) {
                Text("당신의 유형은")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.top, 32)

                Text(viewModel.catType?.rawValue ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.categoryJudgements, id: \.category) { judgement in
                        HStack {
                            Text(judgement.category.rawValue)
                                .font(.headline)
                            Spacer()
                            Text(judgement.isPositive ? "O" : "X")
                                .font(.headline)
                                .foregroundColor(judgement.isPositive ? .green : .red)
                            Text("(\(judgement.score)/5)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
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
                                .padding(.horizontal)

            }
        }
    }
}

#Preview {
    TestView()
}
