import SwiftUI

struct HomeView: View {
    @AppStorage("catTypeRaw") private var catTypeRaw: String = CatType.type4.rawValue
    private var catType: CatType { CatType(rawValue: catTypeRaw) ?? .type4 }

    @AppStorage("nickname") private var nickname: String = ""
    @AppStorage("hasGoal") private var hasGoal: Bool = false
    @State private var isGoalSetting = false

    // RutineView에서 습관 카드 1개 달성 시 별 1개 적립 + 달성률 갱신 (같은 키로 업데이트)
    @AppStorage("starCount") private var starCount: Int = 0
    @AppStorage("weeklyProgress") private var weeklyProgress: Double = 0
    @AppStorage("weeklyCompletedCount") private var weeklyCompletedCount: Int = 0
    // 요일별 완료 개수 (일~토, 하루 최대 3개)
    @AppStorage("dailyCompletedCounts") private var dailyCountsRaw: String = "0,0,0,0,0,0,0"
    @AppStorage("weeklyProgressWeekID") private var weekID: String = ""

    // 목표 프로필(기간·시작일) 기준 현재 주차와 주차별 응원 문구
    private var profile: HabitUserProfile { HabitStore.profile ?? .fallback() }
    private var weekNumber: Int { profile.week() }
    private var weeklyGoalMessage: String {
        Self.goalMessage(totalWeeks: profile.totalWeeks, week: weekNumber)
    }

    // 플랜(2주: 단기 집중형 / 4주: 습관 형성형 / 6주: 장기 변화형)별 주차 문구
    private static func goalMessage(totalWeeks: Int, week: Int) -> String {
        let messages: [String]
        switch totalWeeks {
        case 2:
            messages = [
                "시작이 반이다. 일단은 해보자!",
                "완주가 코앞이야! 마지막 땀방울까지 텐션 올리고 가보자!"
            ]
        case 4:
            messages = [
                "시작이 반이다. 일단은 해보자!",
                "조금씩 몸이 기억하기 시작했어! 지금의 페이스를 유지해!",
                "포기하고 싶은 고비야. 여기만 넘기면 진짜 내 습관이 돼!",
                "마침내 마지막 주! 거침없이 달려서 멋진 완주를 이뤄내자!"
            ]
        default: // 6주
            messages = [
                "시작이 반이다. 일단은 해보자!",
                "아직은 낯설어도 괜찮아. 멈추지 않고 계속하는 게 중요해!",
                "벌써 3주 차! 매일의 작은 노력이 단단한 너를 만들고 있어!",
                "드디어 반환점 돌파! 이제는 관성이 널 앞으로 이끌어줄 거야!",
                "고지가 눈앞에 보여! 지금까지 달려온 너의 열정을 믿어봐!",
                "대망의 파이널! 완벽한 마무리를 향해 전력 질주해 보자!"
            ]
        }
        return messages[min(max(week, 1), messages.count) - 1]
    }

    private static let dayLabels = ["일", "월", "화", "수", "목", "금", "토"]

    // 일요일 0시에 주가 바뀌면 기록이 지난주 것이므로 0으로 표시
    private var isCurrentWeek: Bool {
        weekID == HabitProgressStore.currentWeekID()
    }

    private var displayedWeeklyProgress: Double {
        isCurrentWeek ? weeklyProgress : 0
    }

    private var dailyCounts: [Int] {
        isCurrentWeek ? HabitProgressStore.parseDailyCounts(dailyCountsRaw) : Array(repeating: 0, count: 7)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if hasGoal {
                    weeklyGoalCard
                        .padding(.bottom,20)
                }
                starAndTypeRow
                    .padding(.bottom,20)
                catImageCard
                    .padding(.bottom,20)
                if !hasGoal {
                    goalSettingButton
                        .padding(.bottom,14)
                }
                progressSection
                resetButton
                    .padding(.top, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .scrollIndicators(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("P050"))
        .fullScreenCover(isPresented: $isGoalSetting) {
            GoalSettingView(
                onClose: { isGoalSetting = false },
                catType: catType,
                onStart: {
                    hasGoal = true
                    isGoalSetting = false
                }
            )
        }
    }

    // MARK: - 주차 목표 카드

    private var weeklyGoalCard: some View {
        VStack(spacing: 8) {
            Text("\(weekNumber)주차 목표")
                .font(.F_Bodymedium)
                .foregroundColor(Color("BK"))
            
            Text(weeklyGoalMessage)
                .font(.F_Title)
                .foregroundColor(Color("P400"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("W"))
        .cornerRadius(20)
    }

    // MARK: - 모은 별 + 고양이 유형

    private var starAndTypeRow: some View {
        HStack(alignment: .center,spacing:0) {
            HStack(spacing: 8) {
                Image("ic_star")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color("P400"))
                VStack(alignment: .leading, spacing: 4) {
                    Text("내가 모은 별")
                        .font(.F_footnoteregular)
                        .foregroundColor(Color("G400"))
                    Text("\(starCount)개")
                        .font(.F_Bodybtn)
                        .foregroundColor(Color("P400"))
                }
            }
            .padding(.trailing, 16)
            .padding(.leading, 12)
            .padding(.vertical, 11)
            .background(Color("W"))
            .cornerRadius(12)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(nickname) 님은")
                    .font(.F_footnoteregular)
                    .foregroundColor(Color("G400"))
                Text(catType.rawValue)
                    .font(.F_Title)
                    .foregroundColor(Color("BK"))
            }
        }
    }

    // MARK: - 고양이 이미지 카드

    private var catImageCard: some View {
        Image(CatTypeRepository.content(for: catType).imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 280, height: 280)
    }

    // MARK: - 목표 설정 유도 버튼 (목표 미설정 시)

    private var goalSettingButton: some View {
        Button {
            isGoalSetting = true
        } label: {
            VStack(spacing: 8){
                Text("아직 목표가 없어요!\n목표를 설정하러 가볼까요?")
                    .font(.F_Bodymedium)
                    .foregroundColor(Color("P100"))
                    Text("목표 설정하러 가기 >")
                        .font(.F_Btnlarge)
            }
            .foregroundColor(.white)
            .frame(width: 350, height: 112)
            .background(Color("P400"))
            .cornerRadius(20)
        }
    }

    // MARK: - ⚠️ 임시 테스트용 전체 초기화 버튼

    private var resetButton: some View {
        Button {
            resetAllData()
        } label: {
            Text("전체 초기화 (닉네임부터 다시)")
                .font(.F_footnotemedium)
                .foregroundColor(Color("G400"))
        }
    }

    // 모든 저장 데이터를 지워 온보딩(닉네임 설정)부터 다시 시작
    // hasCompletedSetup이 false가 되면 ContentView가 온보딩 화면으로 전환한다
    private func resetAllData() {
        let keys: [String] = [
            "nickname", "hasCompletedSetup", "hasGoal", "catTypeRaw",
            "starCount", "weeklyProgress", "weeklyCompletedCount",
            "dailyCompletedCounts", "weeklyProgressWeekID",
            "dailyCardStateDate", "dailyFlipped", "dailyCompleted",
            "habitUserProfile", "habitDailyAssignments", "habitCompletionLogs",
            "confettiShownDate"
        ]
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - 이번 주 습관 달성률

    private var progressSection: some View {
        let progress = hasGoal ? displayedWeeklyProgress : 0
        let progressColor = progress >= 0.7 ? Color("P400") : Color("B300")

        return VStack(spacing: 12) {
            HStack(spacing: 0){
                Text("이번 주 습관 달성률")
                    .font(.F_Title)
                    .foregroundColor(Color("BK"))
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.F_Bodyoption)
                    .foregroundColor(progressColor)
            }
            .padding(.horizontal,20)
            CustomProgressBar(progress: progress, trackColor: Color("P050"), fillColor: progressColor, width: 326, height: 20)

            dailyProgressRow
                .padding(.horizontal,12)
        }
        .padding(.top, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
        .background(Color("W"))
        .cornerRadius(20)
        .padding(.top, 8)
    }

    // MARK: - 요일별 달성률

    private var dailyProgressRow: some View {
        HStack {
            ForEach(Array(Self.dayLabels.enumerated()), id: \.offset) { index, day in
                VStack(spacing: 4) {
                    Text(day)
                        .font(.F_caption)
                        .foregroundColor(Color("G500"))
                    dayCircle(count: hasGoal ? dailyCounts[index] : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func dayCircle(count: Int) -> some View {
        Group {
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
        .frame(width: 24, height: 24)
    }

}

#Preview {
    HomeView()
}
