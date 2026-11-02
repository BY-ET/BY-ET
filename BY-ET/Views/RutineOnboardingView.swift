import SwiftUI

struct RutineOnboardingView: View {
    @State private var step: Int = 0
    @State private var swipeForward: Bool = true
    var onFinish: () -> Void

    private let sampleHabit: Habit = HabitRepository.todaysHabits()[0]

    private static let cardWidth: CGFloat = 300
    private static let cardHeight: CGFloat = 490
    private static let cardCorner: CGFloat = 45

    private let guideLabels = ["가이드 1", "가이드 2", "가이드 3", "가이드 4", "가이드 5"]

    private let titleTexts = [
        "매일 운동/식사/환경에 해당하는\n습관카드를 1장씩 받아요!",
        "진행할 습관 카드 뒷면을 눌러서\n카드를 열어주세요!",
        "습관을 수행한 카드는\n'완료했나요?' 버튼을 눌러주세요!",
        "완료한 카드가 제대로 '습관 완료' 도장이\n찍혀있는 지 확인해 주세요!",
        "홈화면에서 이번 주동안 완료한\n습관 카드 갯수를 확인할 수 있어요!"
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 0){
                    progressDots
                        .padding(.leading, 40)
                    Spacer()
                }
                .padding(.top ,120)
                .padding(.bottom, 28)


                    Group {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(guideLabels[step])
                                .font(.F_Bodybtn)
                                .foregroundColor(Color("W"))

                            Text(titleTexts[step])
                                .font(.F_Bodyoption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            if step == 3 {
                                Text("실수로 완료했다면 '되돌리기'를 눌러서 다시 진행할 수 있어요!")
                                    .font(.F_caption)
                                    .foregroundColor(Color("W"))
                            }

                            HStack {
                                Spacer()
                                stepCard
                                Spacer()
                            }
                            .padding(.top, 40)

                            if step == 4 {
                                Text("이번 주 습관 달성률 100%를 목표로\n힘차게 시작해 볼까요?")
                                    .font(.F_Bodyoption)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .id(step)
                    .transition(.asymmetric(
                        insertion: .move(edge: swipeForward ? .trailing : .leading),
                        removal: .move(edge: swipeForward ? .leading : .trailing)
                    ))
                .padding(.bottom,40)

                if step == 4 {
                    AppButton(
                        title: "오늘의 습관 카드 확인하기",
                        style: .pink,
                        size: .large
                    ) {
                        onFinish()
                    }
                    .padding(.horizontal, 24)
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
            
            HStack (spacing: 0){
                Button {
                    swipeForward = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        step -= 1
                    }
                } label: {
                    Image("ic_arrow_left")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color("W"))
                }
                .opacity(step > 0 ? 1 : 0)
                .allowsHitTesting(step > 0)

                Spacer()

                Button {
                    swipeForward = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        step += 1
                    }
                } label: {
                    Image("ic_arrow_right")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color("W"))
                }
                .opacity(step < 4 ? 1 : 0)
                .allowsHitTesting(step < 4)
            }
            .padding(.horizontal, 12)
        }
    }

    // MARK: - Progress Dots

    private var progressDots: some View {
        HStack(spacing: 12) {
            ForEach(0..<5, id: \.self) { i in
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

    // MARK: - Step Cards

    @ViewBuilder
    private var stepCard: some View {
        switch step {
        case 0: step0InfoCard
        case 1: cardBackView
        case 2: cardFrontView1
        case 3: cardFrontView2
        case 4: step4ProgressCard
        default: EmptyView()
        }
    }

    private var step0InfoCard: some View {
        VStack(spacing: 8) {
            Text("습관 카드의 종류는 총 3개에요!\n각각 1장씩 매일 받아요")
                .font(.F_Title).fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color("G500"))
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Image("ic_운동")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color("P400"))

                Image("ic_식단")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color("P400"))

                Image("ic_환경")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color("P400"))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color("W"))
        .cornerRadius(20)
    }

    private var cardBackView: some View {
        Image("onboarding_card_back")
            .resizable()
            .scaledToFill()
            .frame(width: 240,height: 392)
    }

    private var cardFrontView1: some View {
        Image("onboarding_card1")
            .resizable()
            .scaledToFill()
            .frame(width: 240,height: 392)
    }
    private var cardFrontView2: some View {
        Image("onboarding_card2")
            .resizable()
            .scaledToFill()
            .frame(width: 240,height: 392)
    }

    // MARK: - Step 4 Progress Card

    private var step4ProgressCard: some View {
        VStack(spacing: 15) {
            Text("이번 주 습관 달성률은 이렇게 표현돼요!")
                .font(.F_Title)
                .foregroundColor(Color("G500"))
                .multilineTextAlignment(.center)

            HStack(spacing: 40) {
                ForEach([0, 1, 2, 3], id: \.self) { count in
                    VStack(spacing: 12) {
                        progressCircle(count: count)
                            .frame(width: 24, height: 24)
                        Text("\(count)개")
                            .font(.F_footnotemedium)
                            .foregroundColor(Color("G500"))
                    }
                }
            }
        }
        .padding(20)
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
