import SwiftUI

struct GoalSettingView: View {
    @StateObject private var viewModel = GoalSettingViewModel()
    let onClose: () -> Void
    var catType: CatType = .type1
    var onStart: () -> Void = {}

    @State private var timeEditing: TimeEditing?
    @State private var isSettingEnvironment = false
    @AppStorage("nickname") private var nickname: String = ""

    var body: some View {
        VStack(spacing: 32) {
            // 헤더
            HStack {
                Button {
                    if viewModel.isFirstStep {
                        onClose()
                    } else {
                        withAnimation { viewModel.goToPreviousStep() }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("\(nickname)님의 목표 설정")
                Spacer()
            }
            .frame(height: 24)
            .padding(.horizontal)

            SegmentedProgressBar(totalSteps: viewModel.totalSteps, currentStep: viewModel.step)
                .padding(.horizontal)

            // 설정 번호 + 질문
            VStack(alignment: .leading, spacing: 8) {
                Text("설정\(viewModel.step)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("P400"))
                Text(viewModel.questionTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            // 선택지
            ScrollView {
                stepContent
                    .padding(.horizontal)
            }

            // 다음 버튼
            Button {
                if viewModel.isLastStep {
                    // TODO: 목표 저장 로직 연결
                    isSettingEnvironment = true
                } else {
                    withAnimation { viewModel.goToNextStep() }
                }
            } label: {
                Text(viewModel.isLastStep ? "완료" : "다음")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isNextEnabled ? Color("P400") : Color("G200"))
                    .foregroundColor(.white)
                    .cornerRadius(28)
            }
            .disabled(!viewModel.isNextEnabled)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        VStack(spacing: 16) {
            ForEach(options, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    Text(option)
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: 350, height: 56)
                        .background(selected == option ? Color("P200") : Color("W"))
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(selected == option ? Color("P400") : .clear, lineWidth: 2)
                        )
                        .cornerRadius(28)
                }
            }
        }
    }

    // 설정3: 식사시간
    private var mealTimeContent: some View {
        VStack(spacing: 16) {
            // 먹지 않음 체크 버튼 열 상단 라벨
            HStack {
                Spacer()
                Text("먹지 않음")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }

            ForEach(viewModel.meals) { meal in
                HStack(spacing: 12) {
                    Text(meal.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 44, alignment: .leading)

                    Button {
                        timeEditing = TimeEditing(
                            title: "\(meal.name) 식사시간 설정",
                            initialTime: meal.time,
                            onSave: { viewModel.updateMealTime(id: meal.id, time: $0) }
                        )
                    } label: {
                        Text(meal.isSkipped ? "먹지 않음" : viewModel.timeText(meal.time))
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("W"))
                            .foregroundColor(.primary)
                            .cornerRadius(28)
                    }
                    .disabled(meal.isSkipped)

                    Button {
                        viewModel.toggleMealSkipped(id: meal.id)
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(meal.isSkipped ? Color("P400") : Color("G200"))
                            .clipShape(Circle())
                    }
                }
            }
        }
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
                .font(.system(size: 18, weight: .bold))

            ForEach(viewModel.outings) { outing in
                HStack {
                    Text(outing.label)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        timeEditing = TimeEditing(
                            title: "\(outing.label) \(title)",
                            initialTime: outing[keyPath: keyPath],
                            onSave: { viewModel.updateOutingTime(id: outing.id, keyPath: keyPath, time: $0) }
                        )
                    } label: {
                        Text(viewModel.timeText(outing[keyPath: keyPath]))
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 270, height: 40)
                            .background(Color("W"))
                            .foregroundColor(.black)
                            .cornerRadius(22)
                    }

                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top, 24)

            // 선택된 시간 표시 캡슐
            Text(selectedTimeText)
                .font(.body)
                .fontWeight(.bold)
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .background(Color("P050"))
                .cornerRadius(28)
                .padding(.horizontal)

            KoreanTimeWheelPicker(time: $time)
                .padding(.horizontal)

            Button {
                onDone(time)
                dismiss()
            } label: {
                Text("설정 완료")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("P400"))
                    .foregroundColor(.white)
                    .cornerRadius(28)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
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
        HStack(spacing: 12) {
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

    private let rowHeight: CGFloat = 52
    private let visibleRows = 5

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(items, id: \.self) { item in
                    Text(label(item))
                        .font(.system(size: 22, weight: item == scrolledItem ? .bold : .medium))
                        .foregroundColor(item == scrolledItem ? Color("P400") : Color(.systemGray3))
                        .frame(maxWidth: .infinity)
                        .frame(height: rowHeight)
                        .background {
                            if item == scrolledItem {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("P050"))
                                    .padding(.vertical, 3)
                                    .padding(.horizontal, 6)
                            }
                        }
                        .id(item)
                }
            }
            .scrollTargetLayout()
        }
        .frame(height: rowHeight * CGFloat(visibleRows))
        .contentMargins(.vertical, rowHeight * CGFloat(visibleRows / 2), for: .scrollContent)
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
}

#Preview {
    GoalSettingView(onClose: {})
}
