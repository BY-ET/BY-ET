import SwiftUI

struct GoalSetting_LoadingView: View {
    let catType: CatType
    var onStart: () -> Void = {}

    @State private var fillProgress: CGFloat = 0
    @State private var isFinished = false
    @AppStorage("nickname") private var nickname: String = ""

    var body: some View {
        let content = CatTypeRepository.content(for: catType)

        VStack(spacing: 0) {
            Spacer()

            Text(isFinished ? "환경 세팅 완료!" : "환경 세팅 중...")
                .font(.F_Display)
                .foregroundColor(isFinished ? Color("P400") : Color("G300"))
                .padding(.bottom, 60)
            ZStack {
                Image(content.circleImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)

                Circle()
                    .stroke(Color("W"), lineWidth: 30)
                    .frame(width: 240, height: 240)

                // 12시 방향부터 시계 반대 방향으로 채워지는 로딩 원호
                Circle()
                    .trim(from: 0, to: fillProgress)
                    .stroke(Color("P300"), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(x: -1)
            }.padding(.bottom, 40)
            Text(isFinished
                 ? "멀게만 느껴지는 큰 목표는 잠시 잊으세요.\n조금씩 나아지는 내 모습을 지켜보세요."
                 : "\(nickname)님의 최종 목표를 달성하기 위한\n최적의 환경을 만들고 있어요!")
            .font(.F_Bodymedium)
            .foregroundColor(Color("BK"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            AppButton(title: "시작하기", style: .pink, size: .large) {
                onStart()
            }
            .opacity(isFinished ? 1 : 0)
            .disabled(!isFinished)
        }
        .frame(maxWidth: .infinity)
        .background(Color("P050").ignoresSafeArea())
        .onAppear {
            withAnimation(.linear(duration: 4)) {
                fillProgress = 1
            } completion: {
                withAnimation(.easeInOut) {
                    isFinished = true
                }
            }
        }
    }
}

#Preview {
    GoalSetting_LoadingView(catType: .type1)
}
