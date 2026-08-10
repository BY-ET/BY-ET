import SwiftUI

struct TestView: View {
    @StateObject private var viewModel = TestViewModel()
    let onClose: () -> Void
    var onBackToOnboarding: () -> Void = {}

    var body: some View {
        VStack {
            if let question = viewModel.currentQuestion {
                QuestionPageView(
                    question: question,
                    progress: viewModel.progress,
                    totalQuestions: viewModel.totalQuestions,
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
                    },
                    onBack: {
                        // Q1에서는 온보딩 화면으로 복귀
                        if viewModel.canGoBack {
                            withAnimation {
                                viewModel.goToPreviousQuestion()
                            }
                        } else {
                            onBackToOnboarding()
                        }
                    }
                )
            } else if viewModel.isFinished {
                TestResultsView(viewModel: viewModel, onClose: onClose)
            }
        }
        .background(Color("P050"))
        .animation(.easeInOut, value: viewModel.currentQuestion?.id)
    }
}

private struct QuestionPageView: View {
    let question: Question
    let progress: Double
    let totalQuestions: Int
    let isLastQuestion: Bool
    let selectedOption: QuestionOption?
    let onSelect: (QuestionOption) -> Void
    let onShowResult: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                ZStack{
                    Text("유형 탐색")
                        .font(.F_Navigation)
                        .foregroundColor(Color("BK"))
                    HStack (spacing: 0){
                        Button {
                            onBack()
                        } label: {
                            Image("ic_arrow_left")
                                .renderingMode(.template)
                                .foregroundColor(Color("G500"))
                        }
                        Spacer()
                    }
                }.padding(.bottom, 20)

                CustomProgressBar(progress: progress)
                    .padding(.bottom, 8)

                HStack(spacing: 0){
                    Spacer()
                    Text("\(question.order)/\(totalQuestions)")
                        .font(.F_footnoteregular)
                        .foregroundColor(Color("G400"))
                }
                .padding(.bottom, 40)
                
                HStack{
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Q\(question.order).")
                            .font(.F_Headline)
                            .foregroundColor(Color("P400"))
                        
                        Text(question.title)
                            .font(.F_Headline)
                            .foregroundColor(Color("BK"))
                    }
                    Spacer()
                }
                .padding(.bottom, 182)

                VStack(spacing: 8) {
                    ForEach(question.options) { option in
                        AppButton(title: option.text,
                                  style: selectedOption == option ? .questionSelected : .question,
                                  size: .question) {
                            onSelect(option)
                        }
//                        AppButton(title: "테스트 시작하기",
//                                  style: isNicknameValid ? .pink : .gray,
//                                  size: .large) {
//                            savedNickname = nickname.trimmingCharacters(in: .whitespaces)
//                            onStart()
//                        }
                    }
                }
                Spacer()
            }
            VStack(spacing: 0){
                Spacer()
                if isLastQuestion {
                    AppButton(title: "결과보기",
                              style: selectedOption == nil ? .graysoft : .pink,
                              size: .large) {
                        onShowResult()
                    }
                    .disabled(selectedOption == nil)
                    .padding(.bottom, 53)
                }
            }
        }.padding(.horizontal, 20)
    }
}

#Preview {
    TestView(onClose: {})
}
