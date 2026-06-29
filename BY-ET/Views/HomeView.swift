import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("홈 화면")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("나중에 채울 화면이에요")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("W"))
    }
}

#Preview {
    HomeView()
}
