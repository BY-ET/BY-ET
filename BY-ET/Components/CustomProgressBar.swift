import SwiftUI

struct CustomProgressBar: View {
    let progress: Double // 0.0 ~ 1.0
    var trackColor: Color = Color("W")
    var fillColor: Color = Color("P400")
    var width: CGFloat = 350
    var height: CGFloat = 12

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(trackColor)
                .frame(width: width, height: height)

            Capsule()
                .fill(fillColor)
                .frame(width: width * CGFloat(progress), height: height)
                .animation(.easeInOut, value: progress)
        }
    }
}

#Preview {
    CustomProgressBar(progress: 0.6)
}
