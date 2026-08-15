import SwiftUI

enum AppScreen {
    case onboarding
    case survey
    case home
}

struct ContentView: View {
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup: Bool = false
    @State private var currentScreen: AppScreen
    // 테스트용: 결과 화면에 넣어줄 뷰모델 (catType 미설정 시 type1로 표시됨)
    @StateObject private var testViewModel = TestViewModel()
    @AppStorage("hasGoal") private var hasGoal: Bool = false
    @AppStorage("starCount") private var starCount: Int = 0
    @AppStorage("weeklyProgress") private var weeklyProgress: Double = 0

    init() {
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
        _currentScreen = State(initialValue: completed ? .home : .onboarding)
    }

    var body: some View {
        Group {
            switch currentScreen {
            case .onboarding:
                OnboardingView(onStart: {
                    // 새로운 플로우 시작 시 이전 목표 설정 기록·별·달성률 초기화
                    hasGoal = false
                    starCount = 0
                    weeklyProgress = 0
                    currentScreen = .survey
                })
            case .survey:
                TestView(onClose: {
                    hasCompletedSetup = true
                    currentScreen = .home
                }, onBackToOnboarding: {
                    currentScreen = .onboarding
                })
            case .home:
                MainTabView()
            }
        }
    }
}

#Preview {
    ContentView()
}
