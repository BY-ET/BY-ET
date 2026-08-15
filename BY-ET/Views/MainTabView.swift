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
            tabButton(.rutine, icon: "ic_rutin")
            tabButton(.home, icon: "ic_home")
            tabButton(.myCat, icon: "ic_mycat")
        }
        .padding(.top, 12)
        .padding(.horizontal, 20)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                .fill(Color("W"))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(_ tab: MainTab, icon: String) -> some View {
        Button {
            if tab == .rutine && !hasGoal {
                showGoalAlert = true
            } else {
                selectedTab = tab
            }
        } label: {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(selectedTab == tab ? Color("P400") : Color("G200"))
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
}
