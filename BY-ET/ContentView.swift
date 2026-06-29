import SwiftUI

struct ContentView: View {
    @State private var hasStarted = false

    var body: some View {
        Group {
            if hasStarted {
                TestView()
            } else {
                OnboardingView(onStart: {
                    withAnimation{
                        hasStarted = true
                    }
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
