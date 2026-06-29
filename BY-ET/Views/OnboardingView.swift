import SwiftUI

struct OnboardingView: View {
    let onStart: () -> Void

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
                Text("이제는 나한테 딱 맞는\n다이어트를 할 때입니다!\n\n평소 생활 습관만 체크하면,\n8마리의 고양이 중 당신은\n어떤 유형인지 알 수 있습니다.\n\n지금 바로 확인하러 가볼까요?")
                    
                    .multilineTextAlignment(.center)
                Spacer()
                Button {
                    onStart()
                } label: {
                    Text("테스트 시작하기")                        .frame(width: 350, height: 56)
                        .background(Color("P400"))
                        .foregroundColor(.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal)
                .padding(.bottom, 53)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        }
    }
}

#Preview {
    OnboardingView(onStart: {})
}
