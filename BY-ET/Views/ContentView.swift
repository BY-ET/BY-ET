import SwiftUI

enum AppScreen {
    case onboarding
    case survey
    case home
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .onboarding
    // 테스트용: 결과 화면에 넣어줄 뷰모델 (catType 미설정 시 type1로 표시됨)
    @StateObject private var testViewModel = TestViewModel()

    var body: some View {
        Group {
            switch currentScreen {
            case .onboarding:
                OnboardingView(onStart: {
                    currentScreen = .survey
                })
            case .survey:
                TestView(onClose: {
                    currentScreen = .home
                })
            case .home:
                HomeView()
            }
        }
        // 테스트용: TestResultsView부터 바로 확인
//        Group {
//            if currentScreen == .home {
//                HomeView()
//            } else {
//                TestResultsView(viewModel: testViewModel, onClose: {
//                    currentScreen = .home
//                })
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
