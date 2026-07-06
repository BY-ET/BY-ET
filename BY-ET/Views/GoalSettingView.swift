import SwiftUI

struct GoalSettingView: View {
    let onClose: () -> Void

    @State private var step = 1
    @State private var selectedHabit: String?
    @State private var selectedPeriod: String?
    @State private var meals: [MealTime] = MealTime.defaults
    @State private var outings: [OutingTime] = OutingTime.defaults
    @State private var timeEditing: TimeEditing?

    private let totalSteps = 4
    private let habitOptions = ["물 자주 마시기", "과식하지 않기", "술 줄이기", "외식 / 배달음식 줄이기"]
    private let periodOptions = ["2주 뒤", "4주 뒤 (한 달)", "6주 뒤"]

    var body: some View {
        VStack(spacing: 32) {
            // 헤더
            HStack {
                Button {
                    if step > 1 {
                        withAnimation { step -= 1 }
                    } else {
                        onClose()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                Spacer()
                Text("목표 설정")
                Spacer()
            }
            .frame(height: 24)
            .padding(.horizontal)

            CustomProgressBar(progress: Double(step) / Double(totalSteps))
                .padding(.horizontal)

            // 설정 번호 + 질문
            VStack(spacing: 8) {
                Text("설정\(step)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("P400"))
                Text(questionTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // 선택지
            ScrollView {
                stepContent
                    .padding(.horizontal)
            }

            // 다음 버튼
            Button {
                if step < totalSteps {
                    withAnimation { step += 1 }
                } else {
                    // TODO: 목표 저장 로직 연결
                    onClose()
                }
            } label: {
                Text("다음")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isNextEnabled ? Color("P400") : Color("G200"))
                    .foregroundColor(.white)
                    .cornerRadius(28)
            }
            .disabled(!isNextEnabled)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("P050"))
        .animation(.easeInOut, value: step)
        .sheet(item: $timeEditing) { editing in
            TimeWheelSheet(
                title: editing.title,
                time: editing.initialTime,
                onDone: editing.onSave
            )
        }
    }

    private var questionTitle: String {
        switch step {
        case 1: return "어떤 습관 목표를 달성하시겠어요?"
        case 2: return "\(selectedHabit ?? "") 습관이\n언제쯤 형성되길 원하시나요?"
        case 3: return "평소 식사시간을 알려주세요!"
        default: return "평소 외출시간을 알려주세요!"
        }
    }

    private var isNextEnabled: Bool {
        switch step {
        case 1: return selectedHabit != nil
        case 2: return selectedPeriod != nil
        default: return true
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 1:
            optionList(options: habitOptions, selection: $selectedHabit)
        case 2:
            optionList(options: periodOptions, selection: $selectedPeriod)
        case 3:
            mealTimeContent
        default:
            outingTimeContent
        }
    }

    // 설정1, 설정2 공용 선택지 버튼 목록
    private func optionList(options: [String], selection: Binding<String?>) -> some View {
        VStack(spacing: 16) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    Text(option)
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(width: 350, height: 56)
                        .background(selection.wrappedValue == option ? Color("P200") : Color("W"))
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(selection.wrappedValue == option ? Color("P400") : .clear, lineWidth: 2)
                        )
                        .cornerRadius(28)
                }
            }
        }
    }

    // 설정3: 식사시간
    private var mealTimeContent: some View {
        VStack(spacing: 16) {
            ForEach($meals) { $meal in
                HStack(spacing: 12) {
                    Text(meal.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 44, alignment: .leading)

                    Button {
                        timeEditing = TimeEditing(
                            title: "\(meal.name) 식사 시간",
                            initialTime: meal.time,
                            onSave: { meal.time = $0 }
                        )
                    } label: {
                        Text(timeText(meal.time))
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("W"))
                            .foregroundColor(meal.isSkipped ? .secondary : .primary)
                            .cornerRadius(28)
                    }
                    .disabled(meal.isSkipped)

                    Button {
                        meal.isSkipped.toggle()
                    } label: {
                        Text("먹지 않음")
                            .font(.system(size: 14, weight: .medium))
                            .frame(width: 80, height: 56)
                            .background(meal.isSkipped ? Color("P400") : Color("W"))
                            .foregroundColor(meal.isSkipped ? .white : .primary)
                            .cornerRadius(28)
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

            Button {
                let count = outings.filter { $0.isCustom }.count + 1
                outings.append(OutingTime(
                    label: "추가 \(count)",
                    departure: OutingTime.makeTime(9, 0),
                    arrival: OutingTime.makeTime(20, 0),
                    isCustom: true
                ))
            } label: {
                Text("+ 추가하기")
                    .font(.body)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color("W"))
                    .foregroundColor(Color("P400"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color("P400"), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
                    .cornerRadius(28)
            }
        }
    }

    private func outingSection(title: String, keyPath: WritableKeyPath<OutingTime, Date>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))

            ForEach($outings) { $outing in
                HStack {
                    Text(outing.label)
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        timeEditing = TimeEditing(
                            title: "\(outing.label) \(title)",
                            initialTime: outing[keyPath: keyPath],
                            onSave: { outing[keyPath: keyPath] = $0 }
                        )
                    } label: {
                        Text(timeText(outing[keyPath: keyPath]))
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 150, height: 44)
                            .background(Color("P050"))
                            .foregroundColor(.primary)
                            .cornerRadius(22)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color("W"))
        .cornerRadius(20)
    }

    // "오전 9시", "오후 12시 30분" 형태로 변환
    private func timeText(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let prefix = hour < 12 ? "오전" : "오후"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return minute == 0 ? "\(prefix) \(hour12)시" : "\(prefix) \(hour12)시 \(minute)분"
    }
}

// MARK: - 모델

private struct MealTime: Identifiable {
    let id = UUID()
    let name: String
    var time: Date
    var isSkipped: Bool = false

    static let defaults: [MealTime] = [
        MealTime(name: "아침", time: OutingTime.makeTime(9, 0)),
        MealTime(name: "점심", time: OutingTime.makeTime(12, 30)),
        MealTime(name: "저녁", time: OutingTime.makeTime(19, 0))
    ]
}

private struct OutingTime: Identifiable {
    let id = UUID()
    var label: String
    var departure: Date
    var arrival: Date
    var isCustom: Bool = false

    static let defaults: [OutingTime] = [
        OutingTime(label: "평일", departure: makeTime(9, 0), arrival: makeTime(20, 0)),
        OutingTime(label: "주말", departure: makeTime(12, 30), arrival: makeTime(18, 0))
    ]

    static func makeTime(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
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
                .padding(.top, 24)

            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))

            Button {
                onDone(time)
                dismiss()
            } label: {
                Text("완료")
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
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    GoalSettingView(onClose: {})
}
