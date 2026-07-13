import SwiftUI

struct HomeView: View {
    var catType: CatType = .type4

    @AppStorage("nickname") private var nickname: String = ""
    @AppStorage("hasGoal") private var hasGoal: Bool = false
    @State private var isGoalSetting = false

    // RutineView에서 습관 카드 1개 달성 시 별 1개 적립 + 달성률 갱신 (같은 키로 업데이트)
    @AppStorage("starCount") private var starCount: Int = 0
    @AppStorage("weeklyProgress") private var weeklyProgress: Double = 0

    // TODO: 실제 데이터 연동 전 임시 값
    @State private var weekNumber = 1
    @State private var weeklyGoalMessage = "시작이 반이다. 일단은 해보자!"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if hasGoal {
                    weeklyGoalCard
                }
                starAndTypeRow
                catImageCard
                if !hasGoal {
                    goalSettingButton
                }
                progressSection
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
                .font(.body)
                .fontWeight(.semibold)
            Text(weeklyGoalMessage)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(Color("P400"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("W"))
        .cornerRadius(16)
    }

    // MARK: - 모은 별 + 고양이 유형

    private var starAndTypeRow: some View {
        HStack(alignment: .center) {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 26))
                    .foregroundColor(Color("P400"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("내가 모은 별")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("\(starCount)개")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("P400"))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color("W"))
            .cornerRadius(16)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(nickname) 님은")
                    .font(.system(size: 13, weight: .medium))
                Text(catType.rawValue)
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }

    // MARK: - 고양이 이미지 카드

    private var catImageCard: some View {
        Image(CatTypeRepository.content(for: catType).imageName)
            .resizable()
            .scaledToFit()
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(Color("W"))
            .cornerRadius(24)
    }

    // MARK: - 목표 설정 유도 버튼 (목표 미설정 시)

    private var goalSettingButton: some View {
        Button {
            isGoalSetting = true
        } label: {
            VStack {
                Text("아직 목표가 없어요!")
                    .font(.system(size: 16))
                Text("목표를 설정하러 가볼까요?")
                    .font(.system(size: 16))
                HStack(spacing: 2) {
                    Text("목표 설정하러 가기")
                        .font(.system(size: 20, weight: .bold))
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(width: 350, height: 106)
            .background(Color("P400"))
            .cornerRadius(20)
        }
    }

    // MARK: - 이번 주 습관 달성률

    private var progressSection: some View {
        // 목표 미설정 시 달성률은 0%로 표시
        let progress = hasGoal ? weeklyProgress : 0
        // 70% 이상 달성 시 핑크색으로 강조
        let progressColor = progress >= 0.7 ? Color("P400") : Color("B300")

        return VStack(spacing: 12) {
            HStack {
                Text("이번 주 습관 달성률")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(progressColor)
            }
            CustomProgressBar(progress: progress, fillColor: progressColor)
        }
        .padding(.top, 24)
    }

}

#Preview {
    HomeView(catType: .type4)
}
