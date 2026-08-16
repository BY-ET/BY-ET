import SwiftUI

struct GoalSettingView: View {
    @StateObject private var viewModel: GoalSettingViewModel
    let onClose: () -> Void
    var catType: CatType = .type1
    var onStart: () -> Void = {}

    @State private var timeEditing: TimeEditing?
    @State private var isSettingEnvironment = false
    @AppStorage("nickname") private var nickname: String = ""

    init(onClose: @escaping () -> Void,
         catType: CatType = .type1,
         onStart: @escaping () -> Void = {},
         startStep: Int = 1) {
        self.onClose = onClose
        self.catType = catType
        self.onStart = onStart
        _viewModel = StateObject(wrappedValue: GoalSettingViewModel(startStep: startStep))
    }

    var body: some View {
        ZStack{
            VStack(spacing: 0) {
                ZStack{
                    Text("\(nickname)님의 목표 설정")
                        .font(.F_Navigation)
                        .foregroundColor(Color("BK"))
                    HStack (spacing: 0){
                        Button {
                            if viewModel.isFirstStep {
                                onClose()
                            } else {
                                withAnimation { viewModel.goToPreviousStep() }
                            }
                        } label: {
                            Image("ic_arrow_left")
                                .renderingMode(.template)
                                .foregroundColor(Color("G500"))
                        }
                        Spacer()
                    }
                }.padding(.bottom, 20)
                    .padding(.horizontal, 20)
                
                SegmentedProgressBar(totalSteps: viewModel.totalSteps, currentStep: viewModel.step)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 38)
                
                HStack{
                    VStack(alignment: .leading, spacing: 12) {
                        Text("설정 \(viewModel.step).")
                            .font(.F_Headline)
                            .foregroundColor(Color("P400"))
                        Text(viewModel.questionTitle)
                            .font(.F_Headline)
                            .foregroundStyle(Color("BK"))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }.padding(.horizontal, 20)
                
                VStack(spacing: 0){
                    Spacer()
                    stepContent
                    Spacer()
                }
                .padding(.bottom, 80)
            }
            VStack(spacing: 0){
                Spacer()
                // 다음 버튼
                AppButton(title: viewModel.isLastStep ? "완료" : "다음",
                          style: viewModel.isNextEnabled ? .pink : .graysoft,
                          size: .large) {
                    if viewModel.isLastStep {
                        // 유형+목표+기간+시간 프로필 저장 (매칭 엔진이 이 프로필로 습관 선택)
                        HabitStore.saveProfile(viewModel.makeProfile(catType: catType))
                        isSettingEnvironment = true
                    } else {
                        withAnimation { viewModel.goToNextStep() }
                    }
                }
                .disabled(!viewModel.isNextEnabled)
                .padding(.bottom, 20)
            }
        }
        
        .background(Color("P050"))
        .animation(.easeInOut, value: viewModel.step)
        .sheet(item: $timeEditing) { editing in
            TimeWheelSheet(
                title: editing.title,
                time: editing.initialTime,
                onDone: editing.onSave
            )
        }
        .fullScreenCover(isPresented: $isSettingEnvironment) {
            GoalSetting_LoadingView(catType: catType, onStart: onStart)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case 1:
            optionList(options: viewModel.habitOptions, selected: viewModel.selectedHabit) {
                viewModel.selectHabit($0)
            }
        case 2:
            optionList(options: viewModel.periodOptions, selected: viewModel.selectedPeriod) {
                viewModel.selectPeriod($0)
            }
        case 3:
            mealTimeContent
        default:
            outingTimeContent
        }
    }

    // 설정1, 설정2 공용 선택지 버튼 목록
    private func optionList(options: [String], selected: String?, onSelect: @escaping (String) -> Void) -> some View {
        VStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                AppButton(title: option,
                          style: selected == option ? .questionSelected : .question,
                          size: .question) {
                    onSelect(option)
                }
            }
        }
    }

    // 설정3: 식사시간
    private var mealTimeContent: some View {
        VStack(spacing: 0){
            HStack {
                Spacer()
                Text("먹지 않음")
                    .font(.F_footnotemedium)
                    .foregroundColor(Color("G500"))
            }.padding(.bottom, 12)
            
            VStack(spacing: 32) {
                ForEach(viewModel.meals) { meal in
                    HStack(spacing: 12) {
                        Text(meal.name)
                            .font(.F_Bodyoption)

                        AppButton(title: meal.isSkipped ? "먹지 않음" : viewModel.timeText(meal.time),
                                  style: .question,
                                  size: .time) {
                            timeEditing = TimeEditing(
                                title: "\(meal.name) 식사시간 설정",
                                initialTime: meal.time,
                                onSave: { viewModel.updateMealTime(id: meal.id, time: $0) }
                            )
                        }
                        .disabled(meal.isSkipped)

                        Button {
                            viewModel.toggleMealSkipped(id: meal.id)
                        } label: {
                            Image("ic_select")
                                .renderingMode(.template)
                                .foregroundColor(meal.isSkipped ? Color("P400") : Color("G200"))
                                .background(Color("P050"))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }.padding(.horizontal, 20)
    }

    // 설정4: 외출시간
    private var outingTimeContent: some View {
        VStack(spacing: 16) {
            outingSection(title: "나가는 시간", keyPath: \.departure)
            outingSection(title: "돌아오는 시간", keyPath: \.arrival)
        }
    }

    private func outingSection(title: String, keyPath: WritableKeyPath<OutingTime, Date>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.F_Bodyoption)
                .foregroundColor(Color("G400"))

            ForEach(viewModel.outings) { outing in
                HStack {
                    Text(outing.label)
                        .font(.F_Bodyoption)
                        .foregroundColor(Color("BK"))
                    Spacer()
                    Button {
                        timeEditing = TimeEditing(
                            title: "\(outing.label) \(title)",
                            initialTime: outing[keyPath: keyPath],
                            onSave: { viewModel.updateOutingTime(id: outing.id, keyPath: keyPath, time: $0) }
                        )
                    } label: {
                        Text(viewModel.timeText(outing[keyPath: keyPath]))
                            .font(.F_Bodyoption)
                            .foregroundColor(Color("BK"))
                            .frame(width: 303, height: 68)
                            .background(Color("W"))
                            .cornerRadius(34)
                    }

                }
            }
            .padding(.bottom, 5)
        }
        .padding(20)
    }
}

// 시간 선택 시트를 띄우기 위한 컨텍스트
private struct TimeEditing: Identifiable {
    let id = UUID()
    let title: String
    let initialTime: Date
    let onSave: (Date) -> Void
}

// MARK: - 시간 선택 시트

private struct TimeWheelSheet: View {
    let title: String
    @State var time: Date
    let onDone: (Date) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.F_Bodyoption)
                .padding(.top, 16)
                .padding(.bottom, 20)
            Text(selectedTimeText)
                .font(.F_Bodybtn)
                .padding(20)
                .frame(width: 350, height: 56, alignment: .leading)
                .background(Color("P100"))
                .cornerRadius(28)
                .padding(.horizontal,20)

            KoreanTimeWheelPicker(time: $time)
                .padding(.horizontal,20)

            AppButton(title: "다음", style: .pink, size: .large) {
                onDone(time)
                dismiss()
            }
        }
        .presentationDetents([.height(500)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color("W"))
    }

    // "오전 9시", "오후 1시 30분" 형태로 표시
    private var selectedTimeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        let minute = Calendar.current.component(.minute, from: time)
        formatter.dateFormat = minute == 0 ? "a h시" : "a h시 m분"
        return formatter.string(from: time)
    }
}

// MARK: - 커스텀 시간 휠 피커 (오전/오후 · 시 · 분)

private struct KoreanTimeWheelPicker: View {
    @Binding var time: Date

    private static let periods = ["오전", "오후"]
    private static let hours = Array(1...12)
    private static let minutes = Array(stride(from: 0, through: 55, by: 5))

    var body: some View {
        HStack(spacing: 8) {
            WheelColumn(items: Self.periods, selection: periodBinding) { $0 }
            WheelColumn(items: Self.hours, selection: hourBinding) { "\($0)" }
            WheelColumn(items: Self.minutes, selection: minuteBinding) { String(format: "%02d", $0) }
        }
    }

    private var periodBinding: Binding<String> {
        Binding {
            Calendar.current.component(.hour, from: time) < 12 ? "오전" : "오후"
        } set: { newValue in
            let hour = Calendar.current.component(.hour, from: time)
            if newValue == "오전", hour >= 12 {
                setHour(hour - 12)
            } else if newValue == "오후", hour < 12 {
                setHour(hour + 12)
            }
        }
    }

    private var hourBinding: Binding<Int> {
        Binding {
            let hour12 = Calendar.current.component(.hour, from: time) % 12
            return hour12 == 0 ? 12 : hour12
        } set: { newValue in
            let isPM = Calendar.current.component(.hour, from: time) >= 12
            setHour((newValue % 12) + (isPM ? 12 : 0))
        }
    }

    private var minuteBinding: Binding<Int> {
        Binding {
            roundedMinute
        } set: { newValue in
            let hour = Calendar.current.component(.hour, from: time)
            time = Calendar.current.date(bySettingHour: hour, minute: newValue, second: 0, of: time) ?? time
        }
    }

    // 휠 항목은 5분 단위라서 현재 분을 5분 단위로 내림
    private var roundedMinute: Int {
        min(55, (Calendar.current.component(.minute, from: time) / 5) * 5)
    }

    private func setHour(_ hour: Int) {
        time = Calendar.current.date(bySettingHour: hour, minute: roundedMinute, second: 0, of: time) ?? time
    }
}

// 한 열짜리 스냅 휠. 가운데로 스냅된 항목에 분홍 캡슐 하이라이트를 그린다.
private struct WheelColumn<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let label: (Item) -> String

    @State private var scrolledItem: Item?

    private let rowWidth: CGFloat = 80
    private let rowHeight: CGFloat = 48
    private let rowSpacing: CGFloat = 4
    private let visibleRows = 5

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: rowSpacing) {
                ForEach(items, id: \.self) { item in
                    Text(label(item))
                        .font(.F_Navigation)
                        .foregroundColor(color(for: item))
                        .frame(width: rowWidth, height: rowHeight)
                        .background {
                            if item == scrolledItem {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("P050"))
                            }
                        }
                        .id(item)
                }
            }
            .scrollTargetLayout()
        }
        .frame(width: rowWidth,
               height: rowHeight * CGFloat(visibleRows) + rowSpacing * CGFloat(visibleRows - 1))
        .contentMargins(.vertical, (rowHeight + rowSpacing) * CGFloat(visibleRows / 2), for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrolledItem, anchor: .center)
        .scrollIndicators(.hidden)
        .onAppear { scrolledItem = selection }
        .onChange(of: scrolledItem) { _, newValue in
            if let newValue, newValue != selection { selection = newValue }
        }
        .onChange(of: selection) { _, newValue in
            if scrolledItem != newValue { scrolledItem = newValue }
        }
    }

    // 가운데 칸 P400, 위아래 한 칸 G200, 그 밖은 G100
    private func color(for item: Item) -> Color {
        guard let scrolledItem,
              let index = items.firstIndex(of: item),
              let centerIndex = items.firstIndex(of: scrolledItem) else { return Color("G100") }
        switch abs(index - centerIndex) {
        case 0: return Color("P400")
        case 1: return Color("G200")
        default: return Color("G100")
        }
    }
}

#Preview {
    GoalSettingView(onClose: {})
}

#Preview("설정 3") {
    GoalSettingView(onClose: {}, startStep: 3)
}
