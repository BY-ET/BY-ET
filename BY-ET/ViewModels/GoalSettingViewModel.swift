import Foundation

final class GoalSettingViewModel: ObservableObject {
    @Published private(set) var step: Int = 1
    @Published private(set) var selectedHabit: String?
    @Published private(set) var selectedPeriod: String?
    @Published private(set) var meals: [MealTime]
    @Published private(set) var outings: [OutingTime]

    let totalSteps = 4
    let habitOptions: [String]
    let periodOptions: [String]

    init(habitOptions: [String] = GoalOptionRepository.habitOptions,
         periodOptions: [String] = GoalOptionRepository.periodOptions,
         meals: [MealTime] = GoalOptionRepository.defaultMealTimes,
         outings: [OutingTime] = GoalOptionRepository.defaultOutingTimes,
         startStep: Int = 1) {
        self.habitOptions = habitOptions
        self.periodOptions = periodOptions
        self.meals = meals
        self.outings = outings
        self.step = startStep
    }

    var progress: Double {
        Double(step) / Double(totalSteps)
    }
    var isFirstStep: Bool {
        step == 1
    }
    var isLastStep: Bool {
        step == totalSteps
    }

    var questionTitle: String {
        switch step {
        case 1: return "어떤 습관 목표를 달성하시겠어요?"
        case 2: return "\(selectedHabit ?? "") 습관이\n언제쯤 형성되길 원하시나요?"
        case 3: return "평소 식사시간을 알려주세요!"
        default: return "평소 외출시간을 알려주세요!"
        }
    }

    var isNextEnabled: Bool {
        switch step {
        case 1: return selectedHabit != nil
        case 2: return selectedPeriod != nil
        default: return true
        }
    }

    func goToNextStep() {
        guard step < totalSteps else { return }
        step += 1
    }

    func goToPreviousStep() {
        guard step > 1 else { return }
        step -= 1
    }

    func selectHabit(_ habit: String) {
        selectedHabit = habit
    }

    func selectPeriod(_ period: String) {
        selectedPeriod = period
    }

    func updateMealTime(id: UUID, time: Date) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        meals[index].time = time
    }

    func toggleMealSkipped(id: UUID) {
        guard let index = meals.firstIndex(where: { $0.id == id }) else { return }
        meals[index].isSkipped.toggle()
    }

    func updateOutingTime(id: UUID, keyPath: WritableKeyPath<OutingTime, Date>, time: Date) {
        guard let index = outings.firstIndex(where: { $0.id == id }) else { return }
        outings[index][keyPath: keyPath] = time
    }

    func addOutingTime() {
        let count = outings.filter { $0.isCustom }.count + 1
        outings.append(OutingTime(
            label: "추가 \(count)",
            departure: .todayAt(hour: 9, minute: 0),
            arrival: .todayAt(hour: 20, minute: 0),
            isCustom: true
        ))
    }

    /// "오전 9시", "오후 12시 30분" 형태로 변환
    func timeText(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let prefix = hour < 12 ? "오전" : "오후"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return minute == 0 ? "\(prefix) \(hour12)시" : "\(prefix) \(hour12)시 \(minute)분"
    }
}
