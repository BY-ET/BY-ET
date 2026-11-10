import SwiftUI

struct CustomAlertOverlay: View {
    let title: String
    var message: String? = nil
    let primaryLabel: String
    let primaryAction: () -> Void
    var secondaryLabel: String? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(title)
                        .font(.F_Btnlarge)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("BK"))

                    if let message {
                        Text(message)
                            .font(.F_Bodyregular)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("BK"))
                    }
                }

                if let secondaryLabel, let secondaryAction {
                    HStack(spacing: 12) {
                        alertButton(label: secondaryLabel, backgroundColor: Color("G300"), action: secondaryAction)
                        alertButton(label: primaryLabel, backgroundColor: Color("P400"), action: primaryAction)
                    }
                } else {
                    alertButton(label: primaryLabel, backgroundColor: Color("P400"), action: primaryAction)
                }
            }
            .padding(20)
            .padding(.top, 20)
            .background(Color("W"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private func alertButton(label: String, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.F_Btnmedium)
                .foregroundColor(Color("W"))
                .frame(width: 134)
                .frame(height: 48)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }
}

// MARK: - Preview

#Preview("버튼 2개") {
    CustomAlertOverlay(
        title: "목표를 설정해주세요!",
        message: "목표를 설정해야\n오늘의 습관 카드(🔥)를 확인할 수 있어요.",
        primaryLabel: "목표 설정하기",
        primaryAction: {},
        secondaryLabel: "다음에 하기",
        secondaryAction: {}
    )
}

#Preview("버튼 1개") {
    CustomAlertOverlay(
        title: "마이캣은 준비중입니다!",
        message: "조금만 기다려 주세요. 곧 만날 수 있어요.",
        primaryLabel: "확인",
        primaryAction: {}
    )
}
