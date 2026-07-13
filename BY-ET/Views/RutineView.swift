import SwiftUI

struct RutineView: View {
    var body: some View {
        VStack {
            Text("루틴 화면")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("나중에 채울 화면이에요")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("P050"))
    }
}

#Preview {
    RutineView()
}
