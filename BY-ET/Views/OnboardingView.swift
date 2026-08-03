import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    @State private var nickname: String = ""
    @AppStorage("nickname") private var savedNickname: String = ""

    private var isNicknameValid: Bool {
        !nickname.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack{
            Image("test_onboarding_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack {
                Image("logo_Primary_gradient 2")
                    .resizable()
                    .frame(width: 200, height: 64)
                    .padding(.bottom,12)
                    .padding(.top, 82)
                Image("FatCatTest")
                    .resizable()
                    .frame(width: 264, height: 64)
                    .padding(.bottom, 289)
                Text("사용하실 닉네임을 설정해 볼까요?")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                TextField("닉네임을 설정해주세요", text: $nickname)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 24)
                    .frame(width: 350, height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                Spacer()
                Button {
                    savedNickname = nickname.trimmingCharacters(in: .whitespaces)
                    onStart()
                } label: {
                    Text("테스트 시작하기")
                        .frame(width: 350, height: 56)
                        .background(isNicknameValid ? Color("P400") : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(28)
                }
                .disabled(!isNicknameValid)
                .padding(.horizontal)
                .padding(.bottom, 53)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            nickname = savedNickname
        }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
