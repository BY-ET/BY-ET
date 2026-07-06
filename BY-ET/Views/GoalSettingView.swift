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
            VStack(spacing: 8) {
                Text("설정\(viewModel.step)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("P400"))
                Text(viewModel.questionTitle)
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
            ForEach(viewModel.meals) { meal in
                HStack(spacing: 12) {
                    Text(meal.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(width: 44, alignment: .leading)

                    Button {
                        timeEditing = TimeEditing(
                            title: "\(meal.name) 식사 시간",
                            initialTime: meal.time,
                            onSave: { viewModel.updateMealTime(id: meal.id, time: $0) }
                        )
                    } label: {
                        Text(viewModel.timeText(meal.time))
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
                        viewModel.toggleMealSkipped(id: meal.id)
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
                viewModel.addOutingTime()
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
