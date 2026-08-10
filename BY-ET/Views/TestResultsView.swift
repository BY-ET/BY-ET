import SwiftUI

struct TestResultsView: View {
    @ObservedObject var viewModel: TestViewModel
    let onClose: () -> Void

    @State private var showGoalSetting = false
    @AppStorage("hasGoal") private var hasGoal: Bool = false

    var body: some View {
        let content = CatTypeRepository.content(for: viewModel.catType ?? .type1)
        VStack(spacing: 0){
            ZStack{
                Text("테스트 결과")
                    .font(.F_Navigation)
                    .foregroundColor(Color("BK"))
                HStack (spacing: 0){
                    Button {
                        onClose()
                    } label: {
                        Image("ic_close")
                            .renderingMode(.template)
                            .foregroundColor(Color("G500"))
                    }
                    Spacer()
                }
            }
                .padding(.horizontal,20)
            
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ZStack{
                            RoundedRectangle(cornerRadius: 40)
                                .fill(Color("W"))
                                .frame(width: 350, height: 409)
                            VStack(spacing: 20){
                                Text(viewModel.catType?.rawValue ?? "에너지가 넘쳐 흐르는 파워 고양이")
                                    .font(.F_Headline)
                                    .foregroundColor(Color("P400"))
                                    .multilineTextAlignment(.center)
                                Image(content.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 280, height: 280)
                            }
                        }.padding(.bottom, 12)
                            .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 0){
                            Text("당신의 유형은")
                                .font(.F_Headline)
                                .foregroundColor(Color("P400"))
                            Text(viewModel.catType?.rawValue ?? "에너지가 넘쳐 흐르는 파워 고양이!")
                                .font(.F_Headline)
                                .foregroundColor(Color("P400"))
                                .padding(.bottom, 12)
                            Text(content.quote)
                                .font(.F_Bodyoption)
                                .foregroundColor(Color("G500"))
                        }.padding(20)

                        VStack(spacing: 0){
                            ForEach(content.sections) { section in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(section.title)
                                        .font(.F_Bodyoption)
                                        .foregroundColor(Color("BK"))
                                    Text(section.body)
                                        .font(.F_Bodyregular)
                                        .foregroundColor(Color("BK"))
                                        .lineSpacing(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal,20)
                                .padding(.vertical, 28)
                                .background(Color("W"))
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 1)
                                .padding(.bottom, 20)
                            }
                        }.padding(.horizontal,20)
                    }.padding(.bottom, 12)

                    Text("이를 토대로\n목표 습관을 설정할까요?")
                        .font(.F_Headline)
                        .foregroundColor(Color("BK"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)

                    AppButton(title: "목표 설정하러 가기", style: .pink, size: .large) {
                        showGoalSetting = true
                    }
                    .padding(.bottom, 20)

                    Button {
                        onClose()
                    } label: {
                        Text("아니요. 다음에 설정할게요.")
                            .font(.F_Bodyregular)
                            .foregroundColor(Color("G400"))
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color("P050").ignoresSafeArea())
        .fullScreenCover(isPresented: $showGoalSetting) {
            GoalSettingView(onClose: {
                showGoalSetting = false
            }, catType: viewModel.catType ?? .type1, onStart: {
                hasGoal = true
                onClose()
            })
        }
    }
}

#Preview {
    TestResultsView(viewModel: TestViewModel(), onClose: {})
}
