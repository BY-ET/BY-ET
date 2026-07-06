import SwiftUI

struct SegmentedProgressBar: View {
    let totalSteps: Int
    let currentStep: Int // 1부터 시작, 해당 단계까지 채워짐
    var trackColor: Color = Color("W")
    var fillColor: Color = Color("P400")
    var height: CGFloat = 12
    var spacing: CGFloat = 8

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? fillColor : trackColor)
                    .frame(height: height)
                    .animation(.easeInOut, value: currentStep)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SegmentedProgressBar(totalSteps: 4, currentStep: 1)
        SegmentedProgressBar(totalSteps: 4, currentStep: 2)
        SegmentedProgressBar(totalSteps: 4, currentStep: 4)
    }
    .padding()
    .background(Color("P050"))
}
