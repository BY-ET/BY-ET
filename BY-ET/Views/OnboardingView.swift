import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

    @State private var nickname: String
    @AppStorage("nickname") private var savedNickname: String = ""
    @FocusState private var isNicknameFocused: Bool
    @State private var isSuggested: Bool
    @State private var suppressSuggestionReset: Bool = false

    init(onStart: @escaping () -> Void) {
        self.onStart = onStart
        let saved = UserDefaults.standard.string(forKey: "nickname") ?? ""
        if saved.isEmpty {
            _nickname = State(initialValue: NicknameGenerator.random())
            _isSuggested = State(initialValue: true)
        } else {
            _nickname = State(initialValue: saved)
            _isSuggested = State(initialValue: false)
        }
    }

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
                    .foregroundColor(Color("BK"))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                nicknameField
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
        .onTapGesture {
            isNicknameFocused = false
        }
        .ignoresSafeArea(.keyboard)
    }

    private var nicknameField: some View {
        TextField("닉네임을 설정해주세요.", text: $nickname)
            .focused($isNicknameFocused)
            .font(.F_Bodybtn)
            .foregroundColor(isSuggested ? Color("G200") : Color("BK"))
            .multilineTextAlignment(.leading)
            .padding(.leading, 20)
            .padding(.trailing, 52)
            .frame(width: 350, height: 56)
            .background(Color.white)
            .cornerRadius(28)
            .overlay(alignment: .trailing) {
                Button {
                    suppressSuggestionReset = true
                    nickname = NicknameGenerator.random()
                    isSuggested = true
                } label: {
                    Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                        .font(.system(size: 18))
                        .foregroundColor(Color("G200"))
                        .frame(width: 44, height: 44)
                }
                .padding(.trailing, 4)
            }
            .onChange(of: nickname) { _, _ in
                if suppressSuggestionReset {
                    suppressSuggestionReset = false
                } else {
                    isSuggested = false
                }
            }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
