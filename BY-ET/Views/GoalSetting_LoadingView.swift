import SwiftUI

struct GoalSetting_LoadingView: View {
    let catType: CatType
    var onStart: () -> Void = {}

    @State private var fillProgress: CGFloat = 0
    @State private var isFinished = false
    @AppStorage("nickname") private var nickname: String = ""

    var body: some View {
        let content = CatTypeRepository.content(for: catType)

        VStack(spacing: 40) {
            Spacer()

            Text(isFinished ? "환경 세팅 완료!" : "환경 세팅 중...")
                .font(.title)
                .fontWeight(.bold)

            ZStack {
                Image(content.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)

                Circle()
                    .stroke(Color("P200"), lineWidth: 26)
                    .frame(width: 280, height: 280)

                // 12시 방향부터 시계 반대 방향으로 채워지는 로딩 원호
                Circle()
                    .trim(from: 0, to: fillProgress)
                    .stroke(Color("P400"), style: StrokeStyle(lineWidth: 26, lineCap: .round))
                    .frame(width: 280, height: 280)
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(x: -1)
            }
            Text(isFinished
                 ? "멀게만 느껴지는 큰 목표는 잠시 잊으세요.\n조금씩 나아지는 내 모습을 지켜보세요."
                 : "\(nickname)님의 최종 목표를 달성하기 위한\n최적의 환경을 만들고 있어요!")
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()

            Button {
                onStart()
            } label: {
                Text("시작하기")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("P400"))
                    .foregroundColor(.white)
                    .cornerRadius(28)
            }
            .opacity(isFinished ? 1 : 0)
            .disabled(!isFinished)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
