import SwiftUI

struct RutineOnboardingView: View {
    @State private var step: Int = 0
    var onFinish: () -> Void

    private let sampleHabit: Habit = HabitRepository.todaysHabits()[0]

    private static let cardWidth: CGFloat = 300
    private static let cardHeight: CGFloat = 490
    private static let cardCorner: CGFloat = 45

    private let instructionTexts = [
        "매일 3장의 습관 카드를 받을 수 있어요.\n진행할 습관 카드를 눌러 뒤집어 주세요!",
        "습관을 수행한 카드는\n'완료했나요?' 버튼을 눌러주세요!",
        "완료한 카드가 제대로 '습관 완료' 도장이\n찍혀있는 지 확인해 주세요!",
        "홈화면에서 이번 주동안 완료한\n습관카드 갯수를 확인할 수 있어요!"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                progressDots


                if step == 3 {
                    Text(instructionTexts[step])
                        .font(.F_Bodyoption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 110)
                    step4ProgressCard
                        .padding(.horizontal, 52.5)
                        .padding(.vertical, 40)

                    Text("이번 주 습관 달성률 100%를 목표로\n힘차게 시작해 볼까요?")
                        .font(.F_Bodyoption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 52.5)
                        .padding(.bottom, 110)
                } else {
                    Text(instructionTexts[step])
                        .font(.F_Bodyoption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                    stepCard
                        .padding(.bottom, 20)
                }
                if step == 3 {
                    AppButton(
                        title: "오늘의 습관 카드 확인하기",
                        style: .pink,
                        size: .large
                    ) {
                        onFinish()
                    }
                    .padding(.bottom, 40)
                } else {
                    Button("건너뛰기") {
                        onFinish()
                    }
                    .font(.F_Bodyregular)
                    .foregroundColor(Color("G200"))
                }
                Spacer()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard step < 3 else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                step += 1
            }
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { i in
                if i == step {
                    Capsule()
                        .fill(Color("P400"))
                        .frame(width: 32, height: 16)
                } else {
                    Circle()
                        .fill(Color("G100"))
                        .frame(width: 16, height: 16)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: step)
    }

    // MARK: - Step Cards (1-3)

    @ViewBuilder
    private var stepCard: some View {
        switch step {
        case 0: cardBackView
        case 1: cardFrontView(showStamp: false)
        case 2: cardFrontView(showStamp: true)
        default: EmptyView()
        }
    }

    private var cardBackView: some View {
        Color.clear
            .overlay(
                Image("card_back")
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: Self.cardCorner))
            .frame(width: Self.cardWidth, height: Self.cardHeight)
    }

    private func cardFrontView(showStamp: Bool) -> some View {
        VStack(spacing: 0) {
            Image(sampleHabit.iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(Color("P400"))
                .padding(.top, 16)

            Text(sampleHabit.text)
                .font(.F_Headline)
                .foregroundColor(Color("BK"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 12)
                .padding(.top, 16)

            Image(sampleHabit.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)
                .overlay(alignment: .bottomTrailing) {
                    if showStamp {
                        Image("rutine_done")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                }

            if !showStamp {
                AppButton(title: "완료했나요?", style: .pink, size: .medium) {}
                    .allowsHitTesting(false)
                    .padding(.top, 12)
            }

            Spacer()
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .background(Color("W"))
        .cornerRadius(Self.cardCorner)
    }

    // MARK: - Step 4 Progress Card

    private var step4ProgressCard: some View {
        VStack(spacing: 16) {
            Text("이번 주 습관 달성률은 이렇게 표현돼요!")
                .font(.F_Title)
                .foregroundColor(Color("G500"))
                .multilineTextAlignment(.center)

            HStack(spacing: 0) {
                ForEach([0, 1, 2, 3], id: \.self) { count in
                    VStack(spacing: 6) {
                        progressCircle(count: count)
                            .frame(width: 24, height: 24)
                        Text("\(count)개")
                            .font(.F_caption)
                            .foregroundColor(Color("G500"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color("W"))
        .cornerRadius(20)
    }

    @ViewBuilder
    private func progressCircle(count: Int) -> some View {
        switch count {
        case 1:
            Image("ic_one_third")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("P200"))
        case 2:
            Image("ic_two_third")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("P300"))
        case 3:
            Image("ic_circle")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color("P400"))
        default:
            Circle()
                .fill(Color("W"))
                .overlay(Circle().stroke(Color("G100"), lineWidth: 1.5))
        }
    }
}

#Preview {
    ZStack {
        Color("P050").ignoresSafeArea()
        RutineOnboardingView(onFinish: {})
    }
}
