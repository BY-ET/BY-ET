import SwiftUI

enum AppScreen {
    case onboarding
    case survey
    case home
}

// fullScreenCover(item:)에 CatType을 바로 넘기기 위한 채택
extension CatType: Identifiable {
    var id: String { rawValue }
}

struct ContentView: View {
    // ⚠️ 임시 확인용: true면 앱 실행 시 유형 선택 → 목표설정 → 습관카드만 바로 확인할 수 있음
    // 확인이 끝나면 false로 되돌리면 원래 플로우(온보딩 → 테스트 → 홈)로 복구됨
    private let showGoalAndRutineOnly = false
    @State private var goalSettingType: CatType?
    @State private var showRutine = false
    @AppStorage("catTypeRaw") private var catTypeRaw: String = CatType.type4.rawValue

    @AppStorage("hasCompletedSetup") private var hasCompletedSetup: Bool = false
    @State private var currentScreen: AppScreen
    @StateObject private var testViewModel = TestViewModel()
    @AppStorage("hasGoal") private var hasGoal: Bool = false
    @AppStorage("starCount") private var starCount: Int = 0
    @AppStorage("weeklyProgress") private var weeklyProgress: Double = 0

    init() {
        let completed = UserDefaults.standard.bool(forKey: "hasCompletedSetup")
        _currentScreen = State(initialValue: completed ? .home : .onboarding)
    }

    var body: some View {
        if showGoalAndRutineOnly {
            goalAndRutineOnlyFlow
        } else {
            mainFlow
        }
    }

    // MARK: - ⚠️ 임시 확인용 플로우 (유형 선택 → 목표설정 → 습관카드)

    private var goalAndRutineOnlyFlow: some View {
        ZStack {
            if showRutine {
                RutineView()
                    .overlay(alignment: .topTrailing) {
                        Button("유형 다시 선택") { showRutine = false }
                            .font(.F_footnotemedium)
                            .foregroundColor(Color("G500"))
                            .padding(.top, 16)
                            .padding(.trailing, 20)
                    }
            } else {
                catTypePicker
            }
        }
        .fullScreenCover(item: $goalSettingType) { type in
            GoalSettingView(
                onClose: { goalSettingType = nil },
                catType: type,
                onStart: {
                    UserDefaults.standard.removeObject(forKey: "habitDailyAssignments")
                    UserDefaults.standard.set("", forKey: "dailyCardStateDate")
                    showRutine = true
                    goalSettingType = nil
                }
            )
        }
    }

    private var catTypePicker: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("테스트할 고양이 유형 선택")
                    .font(.F_Navigation)
                    .foregroundColor(Color("BK"))
                    .padding(.top, 40)
                    .padding(.bottom, 8)

                ForEach(CatType.allCases, id: \.self) { type in
                    let mapping = TypeMapping.mapping(for: type)
                    Button {
                        catTypeRaw = type.rawValue
                        goalSettingType = type
                    } label: {
                        VStack(spacing: 4) {
                            Text(type.rawValue)
                                .font(.F_Bodyoption)
                                .foregroundColor(Color("BK"))
                            Text("\(mapping.context.rawValue) · 우선목표: \(mapping.priorityGoal.rawValue) · 시작난이도 \(mapping.startDifficulty)")
                                .font(.F_footnotemedium)
                                .foregroundColor(Color("G500"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(catTypeRaw == type.rawValue ? Color("P100") : Color("W"))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color("P050").ignoresSafeArea())
    }

    // MARK: - 원래 플로우

    private var mainFlow: some View {
        Group {
            switch currentScreen {
            case .onboarding:
                OnboardingView(onStart: {
                    // 새로운 플로우 시작 시 이전 목표 설정 기록·별·달성률 초기화
                    hasGoal = false
                    starCount = 0
                    weeklyProgress = 0
                    currentScreen = .survey
                })
            case .survey:
                TestView(onClose: {
                    hasCompletedSetup = true
                    currentScreen = .home
                }, onBackToOnboarding: {
                    currentScreen = .onboarding
                })
            case .home:
                MainTabView()
            }
        }
        .onChange(of: hasCompletedSetup) { _, completed in
            if !completed { currentScreen = .onboarding }
        }
    }
}

#Preview {
    ContentView()
}
