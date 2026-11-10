import SwiftUI

struct MyCatView: View {
    @AppStorage("catTypeRaw") private var catTypeRaw: String = CatType.type4.rawValue
    @AppStorage("totalStars") private var totalStars: Int = 0
    @AppStorage("materialProgress") private var materialProgress: Double = 0.3

    private var catType: CatType { CatType(rawValue: catTypeRaw) ?? .type4 }
    private var catContent: CatTypeContent { CatTypeRepository.content(for: catType) }

    private var myCatImageName: String {
        switch catType {
        case .type1: return "MC_type1"
        case .type2: return "MC_type2"
        case .type3: return "MC_type3"
        case .type4: return "MC_type4"
        case .type5: return "MC_type5"
        case .type6: return "MC_type6"
        case .type7: return "MC_type7"
        case .type8: return "MC_type8"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 바
            ZStack {
                Text("마이캣")
                    .font(.F_Navigation)
                    .foregroundStyle(Color("BK"))
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Spacer()
                    Button {
                    } label: {
                        Image("ic_setting")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .foregroundStyle(Color("G500"))
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 12)
            .padding(.bottom, 20)

            // 별 & 재료 진행률
            VStack(spacing: 12){
                HStack(alignment: .top, spacing: 0) {
                    HStack(spacing: 8) {
                        Image("ic_star")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color("P400"))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("내가 모은 별")
                                .font(.F_footnotemedium)
                                .foregroundStyle(Color("G400"))
                            Text("\(totalStars)개")
                                .font(.F_Title)
                                .foregroundStyle(Color("P400"))
                        }
                    }
                    .padding(.vertical,9.5)
                    .padding(.leading,12)
                    .padding(.trailing,16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("W"))
                    )
                    Spacer()
                    // 재료 진행률
                    VStack(alignment: .center, spacing: 6) {
                        HStack(spacing: 2) {
                            Text("남은 체력")
                                .font(.F_caption)
                                .foregroundStyle(Color("BK"))
                            Button{
                                
                            } label: {
                                Image("ic_?")
                            }
                            Spacer()
                            Text("\(Int(materialProgress * 100))%")
                                .font(.F_Title)
                                .foregroundStyle(Color("P400"))
                        }.frame(width: 170)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("P050"))
                                    .frame(width: 166, height: 12)
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("P400"))
                                    .frame(width: 30, height: 12)
                            }
                        }.frame(width: 166, height: 12)
                    }
                    .frame(width: 194, height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("W"))
                    )
                }
                HStack{
                    AppButton(
                        title: "상점",
                        icon: "ic_shop",
                        iconSize: 34,
                        style: .pink,
                        size: .medium)
                    {

                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            Spacer()

            Image(myCatImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)

            Spacer()

            AppButton(
                title: "마이캣 보관함 가기",
                style: .pink,
                size: .large
            ) {
            }.padding(20)
        }
        .background {
            Image("MC_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    MyCatView()
}
