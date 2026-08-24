import Foundation

// 습관 카드 데이터
struct Habit: Identifiable {
    let id: Int          // 화면 카드 순서 (0~2)
    let code: String     // 습관 DB 코드 (D01/E01/X01 등, 완료 기록에 사용)
    let title: String
    let iconName: String
    let text: String
    let imageName: String
}

// 습관 부문: 운동(exercise), 식욕(eat), 환경(environment)
enum HabitCategory: String, CaseIterable {
    case exercise
    case eat
    case environment

    var title: String {
        switch self {
        case .exercise: return "운동"
        case .eat: return "식욕"
        case .environment: return "환경"
        }
    }

    var iconName: String {
        switch self {
        case .exercise: return "ic_운동"
        case .eat: return "ic_식단"
        case .environment: return "ic_환경"
        }
    }
}

// 오늘의 습관 카드 제공 (실제 선택·저장은 HabitEngine이 담당)
enum HabitRepository {
    // 날짜 기준 그날의 습관 카드 3개 (운동/식욕/환경 각 1개)
    static func todaysHabits(for date: Date = .now) -> [Habit] {
        HabitEngine.todaysHabits(for: date)
    }
}
