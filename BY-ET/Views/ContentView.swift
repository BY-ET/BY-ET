import SwiftUI

enum AppScreen {
    case onboarding
    case survey
    case home
}

// fullScreenCover(item:)에 CatType을 바로 넘기기 위한 채택
extension CatType: Identifiable {
    var id: String { rawValue }
}

struct ContentView: View {
    @State private var goalSettingType: CatType?
    @State private var showRutine = false
    @AppStorage("catTypeRaw") private var catTypeRaw: String = CatType.type4.rawValue

    @AppStorage("hasCompletedSetup") private var hasCompletedSetup: Bool = false
    @State private var currentScreen: AppScreen
    @StateObject private var testViewModel = TestViewModel()
    @AppStorage("hasGoal") private var hasGoal: Bool = false
    @AppStorage("starCount") private var starCount: Int = 0
    @AppStorage("weeklyProgress") private var weeklyProgress: Double = 0

    init() {
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
        _currentScreen = State(initialValue: completed ? .home : .onboarding)
    }

    var body: some View {
        mainFlow
    }
    
    private var mainFlow: some View {
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
        .onChange(of: hasCompletedSetup) { _, completed in
            if !completed { currentScreen = .onboarding }
        }
    }
}

#Preview {
    ContentView()
}
