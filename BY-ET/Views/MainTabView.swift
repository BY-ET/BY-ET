import SwiftUI

enum MainTab {
    case rutine
    case home
    case myCat
}

struct MainTabView: View {
    @AppStorage("catTypeRaw") private var catTypeRaw: String = CatType.type4.rawValue
    private var catType: CatType { CatType(rawValue: catTypeRaw) ?? .type4 }

    @State private var selectedTab: MainTab = .home
    @State private var showGoalAlert = false
    @State private var isGoalSetting = false
    @AppStorage("hasGoal") private var hasGoal: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // 탭을 전환해도 각 뷰의 상태(카드 뒤집힘/완료 등)가 유지되도록
            // 뷰를 제거하지 않고 opacity로만 전환
            ZStack {
                RutineView()
                    .opacity(selectedTab == .rutine ? 1 : 0)
                    .allowsHitTesting(selectedTab == .rutine)
                HomeView()
                    .opacity(selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(selectedTab == .home)
                MyCatView()
                    .opacity(selectedTab == .myCat ? 1 : 0)
                    .allowsHitTesting(selectedTab == .myCat)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            tabBar
        }
        .background(Color("P050"))
        .alert("목표를 설정해주세요!", isPresented: $showGoalAlert) {
            Button("닫기", role: .cancel) {}
            Button("목표 설정하기") { isGoalSetting = true }
        } message: {
            Text("목표를 설정해야 오늘의 습관 카드를 확인할 수 있어요.")
        }
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

    // MARK: - 하단 탭 바

    private var tabBar: some View {
        HStack {
            tabButton(.rutine, icon: "flame")
            tabButton(.home, icon: "house.fill")
            tabButton(.myCat, icon: "cat.fill")
        }
        .padding(.top, 16)
        .background(Color("W").ignoresSafeArea(edges: .bottom))
    }

    private func tabButton(_ tab: MainTab, icon: String) -> some View {
        Button {
            // 목표 미설정 시 루틴 탭 진입을 막고 알림 표시
            if tab == .rutine && !hasGoal {
                showGoalAlert = true
            } else {
                selectedTab = tab
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? Color("P400") : Color("G300"))
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
}
