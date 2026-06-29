import SwiftUI

struct TestResultsView: View {
    @ObservedObject var viewModel: TestViewModel
    let onClose: () -> Void
    
    var body: some View {
        let content = CatTypeRepository.content(for: viewModel.catType ?? .type1)
        
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("테스트 결과")
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color("W"))
                        .frame(width: 350, height: 404)
                    VStack{
                        Text(viewModel.catType?.rawValue ?? "")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("P400"))
                            .multilineTextAlignment(.center)
                        Image(content.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4){
                    Text("당신의 유형은")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("P400"))
                    Text(viewModel.catType?.rawValue ?? "")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("P400"))
                        .padding(.bottom, 10)
                    Text(content.quote)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("P400"))
                        .padding(.bottom, 10)
                }.padding(.horizontal,16)
                

                VStack(alignment: .leading,spacing: 4){
                    ForEach(content.sections) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title)
                                .font(.system(size: 18, weight: .bold))
                            Text(section.body)
                                .font(.system(size: 15))
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color("W"))
                        .cornerRadius(20)
                        .padding(.bottom, 10)
                    }
                }.padding(.horizontal,20)
            }
            .padding(.bottom, 12)
            Text("이를 토대로\n목표 습관을 설정할까요?")
                .font(.system(size: 22, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom,20)
            Button {
            } label: {
                Text("목표 설정하러 가기")
                    .frame(width: 350, height: 56)
                    .background(Color("P400"))
                    .foregroundColor(.white)
                    .cornerRadius(28)
                }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    TestResultsView(viewModel: TestViewModel(), onClose: {})
}
