import SwiftUI

enum AppScreen {
    case onboarding
    case survey
    case home
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .onboarding

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
