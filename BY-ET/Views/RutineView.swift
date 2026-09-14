import SwiftUI
import Lottie

struct RutineView: View {
    @Environment(\.scenePhase) private var scenePhase

    // 오늘의 습관 카드 3개 (운동/식욕/환경, 매일 새로 선택)
    @State private var habits: [Habit] = HabitRepository.todaysHabits()

    @State private var currentIndex: Int? = 0
    @State private var flipped: [Bool] = [false, false, false]
    @State private var completed: [Bool] = [false, false, false]

    // 하루 3개를 모두 완료한 순간 컨페티를 하루에 한 번만 재생
    @AppStorage("confettiShownDate") private var confettiShownDate: String = ""
    @State private var showConfetti = false

    // 카드 상태를 날짜별로 유지 (날짜가 바뀌면 리셋, 앱을 껐다 켜도 오늘 상태 유지)
    @AppStorage("dailyCardStateDate") private var cardStateDate: String = ""
    @AppStorage("dailyFlipped") private var flippedRaw: String = "0,0,0"
    @AppStorage("dailyCompleted") private var completedRaw: String = "0,0,0"

    private static let cardWidth: CGFloat = 300
    private static let cardHeight: CGFloat = 490
    private static let cardSpacing: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            Text("오늘의 다이어트 습관")
                .font(.F_Navigation)
                .foregroundColor(Color("BK"))
                .padding(.top, 12)

            Text("진행할 습관 카드를 선택해 확인해 주세요")
                .font(.F_Bodymedium)
                .foregroundColor(Color("BK"))
                .padding(.top, 32)

            habitIconRow
                .padding(.top, 20)

            habitCardPager
                .padding(.top, 20)

            Spacer(minLength: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("P050"))
        .onAppear { refreshForToday() }
        // 자정이 지난 뒤 앱을 다시 열었을 때도 새 카드로 교체
        .onChange(of: scenePhase) {
            if scenePhase == .active { refreshForToday() }
        }
        .onChange(of: flipped) {
            flippedRaw = HabitProgressStore.encodeFlags(flipped)
        }
        .onChange(of: completed) {
            completedRaw = HabitProgressStore.encodeFlags(completed)
            celebrateIfAllCompleted()
        }
        .overlay {
            if showConfetti {
                // 고양이 위로 컨페티가 터지도록 겹쳐서 화면 가로 꽉 차게 중앙 배치
                ZStack {
                    LottieView(animation: .named("goal_cat"))
                        .playing(loopMode: .playOnce)
                        .resizable()
                        .aspectRatio(3.0 / 2.0, contentMode: .fit)

                    LottieView(animation: .named("confetti"))
                        .playing(loopMode: .playOnce)
                        .resizable()
                        // 컨페티(3초)가 더 길어서 끝나는 시점에 둘 다 사라짐
                        .animationDidFinish { _ in
                            showConfetti = false
                        }
                        .aspectRatio(1, contentMode: .fit)
                }
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            }
        }
    }

    // 오늘의 습관 3개를 모두 완료한 순간 컨페티 재생 (앱 재실행 시 중복 재생 방지)
    private func celebrateIfAllCompleted() {
        guard completed.allSatisfy({ $0 }),
              confettiShownDate != HabitProgressStore.todayID() else { return }
        confettiShownDate = HabitProgressStore.todayID()
        showConfetti = true
    }

    // 날짜가 바뀌었으면 오늘의 새 카드로 교체하고 상태 리셋, 같은 날이면 저장된 상태 복원
    private func refreshForToday() {
        let today = HabitProgressStore.todayID()
        if cardStateDate != today {
            cardStateDate = today
            flippedRaw = "0,0,0"
            completedRaw = "0,0,0"
            habits = HabitRepository.todaysHabits()
            currentIndex = 0
        }
        flipped = HabitProgressStore.parseFlags(flippedRaw)
        completed = HabitProgressStore.parseFlags(completedRaw)
    }

    // MARK: - 습관 아이콘 (현재 카드에 따라 색상 변경)

    private var habitIconRow: some View {
        HStack(spacing: 12) {
            ForEach(habits) { habit in
                Image(habit.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundColor(habit.id == (currentIndex ?? 0) ? Color("P400") : Color("G200"))
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
    }

    // MARK: - 습관 카드 페이저

    private var habitCardPager: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                HStack(spacing: Self.cardSpacing) {
                    ForEach(habits) { habit in
                        HabitCardView(
                            habit: habit,
                            isFlipped: $flipped[habit.id],
                            isCompleted: $completed[habit.id]
                        )
                        .frame(width: Self.cardWidth, height: Self.cardHeight)
                        .id(habit.id)
                    }
                }
                .scrollTargetLayout()
            }
            // 카드가 항상 가운데 오도록 좌우 여백 지정
            .contentMargins(.horizontal, (geometry.size.width - Self.cardWidth) / 2, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentIndex)
            .scrollIndicators(.hidden)
        }
        .frame(height: Self.cardHeight)
    }
}

// MARK: - 습관 카드 (탭하면 뒤집히는 카드)

struct HabitCardView: View {
    let habit: Habit
    @Binding var isFlipped: Bool
    @Binding var isCompleted: Bool

    // 습관 완료 1개당 별 1개 적립 (HomeView와 같은 키)
    @AppStorage("starCount") private var starCount: Int = 0

    // 이번 주 습관 달성률: 완료 개수 / 21 (하루 3개 * 7일), HomeView와 같은 키
    @AppStorage("weeklyProgress") private var weeklyProgress: Double = 0
    @AppStorage("weeklyCompletedCount") private var weeklyCompletedCount: Int = 0
    // 요일별 완료 개수 (일~토, 하루 최대 3개)
    @AppStorage("dailyCompletedCounts") private var dailyCountsRaw: String = "0,0,0,0,0,0,0"
    // 주가 바뀌면 기록을 리셋하기 위한 주 식별자 (예: "2026-30")
    @AppStorage("weeklyProgressWeekID") private var weekID: String = ""

    private static let cornerRadius: CGFloat = 45

    var body: some View {
        ZStack {
            // 앞면: 습관 이미지
            cardFront
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))

            // 뒷면: 카드 뒷면 이미지
            cardBack
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .onTapGesture {
            // 이미 깐 카드는 다시 뒤집히지 않음
            guard !isFlipped else { return }
            withAnimation(.easeInOut(duration: 0.6)) {
                isFlipped = true
            }
        }
    }

    private var cardFront: some View {
        VStack(spacing: 0) {
            Image(habit.iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(Color("P400"))
                .padding(.top, 16)

            Text(habit.text)
                .font(.F_Headline)
                .foregroundColor(Color("BK"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 16)

            habitImage
                .overlay(alignment: .bottomTrailing) {
                    if isCompleted {
                        Image("rutine_done")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120)
                    }
                }

            completeButton
                .padding(.top,12)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("W"))
        .cornerRadius(Self.cornerRadius)
    }

    private var habitImage: some View {
        Image(habit.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 260, height: 260)
    }

    private var completeButton: some View {
        AppButton(
            title: isCompleted ? "완료!" : "완료했나요?",
            style: isCompleted ? .pink : .pinkOutline,
            size: .medium
        ) {
            withAnimation(.spring(duration: 0.4)) {
                isCompleted = true
            }
            starCount += 1
            updateWeeklyProgress()
            // completion_logs에 완료 기록 (주차 전환 시 난이도 재계산의 근거)
            HabitStore.log(code: habit.code, dateID: HabitProgressStore.todayID(), status: .completed)
        }
        .disabled(isCompleted)
    }

    // 이번 주 완료 개수를 1 올리고 주간/요일별 달성률 갱신 (주가 바뀌었으면 0부터 다시 시작)
    private func updateWeeklyProgress() {
        let currentWeekID = HabitProgressStore.currentWeekID()
        if weekID != currentWeekID {
            weekID = currentWeekID
            weeklyCompletedCount = 0
            dailyCountsRaw = HabitProgressStore.encodeDailyCounts(Array(repeating: 0, count: 7))
        }
        weeklyCompletedCount = min(weeklyCompletedCount + 1, HabitProgressStore.cardsPerWeek)
        weeklyProgress = Double(weeklyCompletedCount) / Double(HabitProgressStore.cardsPerWeek)

        var dailyCounts = HabitProgressStore.parseDailyCounts(dailyCountsRaw)
        let today = HabitProgressStore.todayIndex()
        dailyCounts[today] = min(dailyCounts[today] + 1, HabitProgressStore.cardsPerDay)
        dailyCountsRaw = HabitProgressStore.encodeDailyCounts(dailyCounts)
    }

    // 앞면과 동일하게 컨테이너 크기를 그대로 채움
    private var cardBack: some View {
        Color.clear
            .overlay(
                Image("card_back")
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
    }
}

#Preview {
    RutineView()
}

#Preview("카드 앞면") {
    HabitCardView(
        habit: HabitRepository.todaysHabits()[0],
        isFlipped: .constant(true),
        isCompleted: .constant(false)
    )
    .frame(width: 300, height: 490)
}
