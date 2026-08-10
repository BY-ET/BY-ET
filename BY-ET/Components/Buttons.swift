import SwiftUI

struct AppButton: View {

    enum Style {
        case red        // 1번 - 바탕 R300, 내용 W
        case pinkText   // 2번 - 바탕 W, 내용 P400
        case pink       // 3번 - 바탕 P400, 내용 W
        case pinkOutline // 4번 - 바탕 W, stroke P400(weight 2), 내용 P400
        case gray      // 5번 - 바탕 G300, 내용 W
        case graysoft  // 6번 - 바탕 G200, 내용 G100
    }

    enum Size {
        case large     // 350×60, Btnlarge, 아이콘 O
        case medium    // 134×48, Btnmedium, 아이콘 O
        case small     // 64×40, Btnmedium, 아이콘 X
    }

    let title: String
    var icon: String? = nil
    let style: Style
    let size: Size
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if size != .small, let iconName = icon {
                    Image(iconName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                }
                Text(title)
                    .font(titleFont)
            }
            .foregroundColor(contentColor)
            .frame(width: buttonWidth, height: buttonHeight)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Size values

    private var buttonWidth: CGFloat {
        switch size {
        case .large: return 350
        case .medium: return 134
        case .small: return 64
        }
    }

    private var buttonHeight: CGFloat {
        switch size {
        case .large: return 60
        case .medium: return 48
        case .small: return 40
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .large: return 28
        case .medium: return 24
        case .small: return 20
        }
    }

    private var iconSize: CGFloat {
        size == .large ? 24 : 20
    }

    private var titleFont: Font {
        size == .large ? .Btnlarge : .Btnmedium
    }

    // MARK: - Color values

    private var backgroundColor: Color {
        switch style {
        case .red:         return Color("R300")
        case .pinkText:    return Color("W")
        case .pink:        return Color("P400")
        case .pinkOutline: return Color("W")
        case .gray:       return Color("G300")
        case .graysoft:   return Color("G200")
        }
    }

    private var contentColor: Color {
        switch style {
        case .red:         return Color("W")
        case .pinkText:    return Color("P400")
        case .pink:        return Color("W")
        case .pinkOutline: return Color("P400")
        case .gray:       return Color("W")
        case .graysoft:   return Color("G100")
        }
    }

    private var borderColor: Color {
        switch style {
        case .pinkOutline: return Color("P400")
        default:           return .clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .pinkOutline: return 2
        default:           return 0
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach([AppButton.Style.red, .pinkText, .pink, .pinkOutline, .gray, .graysoft], id: \.self) { style in
                HStack(spacing: 12) {
                    AppButton(title: "Btn", icon: "ic_shop", style: style, size: .medium) {}
                    AppButton(title: "Btn", style: style, size: .small) {}
                }
                AppButton(title: "Btn", icon: "ic_shop", style: style, size: .large) {}
            }
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
