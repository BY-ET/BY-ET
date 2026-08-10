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
            VStack (spacing: 0){
                Image("logo_Primary_gradient 2")
                    .resizable()
                    .frame(width: 200, height: 64)
                    .padding(.bottom,12)
                    .padding(.top, 82)
                Image("FatCatTest")
                    .resizable()
                    .frame(width: 264, height: 64)
                    .padding(.bottom, 293)
                Text("사용하실 닉네임을 설정해 볼까요?")
                    .font(.F_Btnmedium)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                TextField("닉네임을 설정해주세요", text: $nickname)
                    .font(.F_Bodybtn)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .frame(width: 350, height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                    .padding(.bottom, 140)
                AppButton(title: "테스트 시작하기",
                          style: isNicknameValid ? .pink : .gray,
                          size: .large) {
                    savedNickname = nickname.trimmingCharacters(in: .whitespaces)
                    onStart()
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
