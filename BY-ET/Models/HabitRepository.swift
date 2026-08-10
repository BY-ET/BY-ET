import Foundation

// 습관 카드 데이터
struct Habit: Identifiable {
    let id: Int
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

// 매일 부문별 습관 1개씩 순환 선택 (1번 → 2번 → ... → 10번 → 1번)
enum HabitRepository {
    static let habitsPerCategory = 10

    // 부문별 습관 문구 (인덱스+1 == 이미지 번호)
    // TODO: 2~10번 실제 습관 문구로 교체
    private static let texts: [HabitCategory: [String]] = [
        .exercise: [
            "3층 이하는 엘리베이터 대신\n계단을 이용하기",
            "운동 습관 2",
            "운동 습관 3",
            "운동 습관 4",
            "운동 습관 5",
            "운동 습관 6",
            "운동 습관 7",
            "운동 습관 8",
            "운동 습관 9",
            "운동 습관 10"
        ],
        .eat: [
            "식사 30분 전, \n물 500ml 마시기",
            "식욕 습관 2",
            "식욕 습관 3",
            "식욕 습관 4",
            "식욕 습관 5",
            "식욕 습관 6",
            "식욕 습관 7",
            "식욕 습관 8",
            "식욕 습관 9",
            "식욕 습관 10"
        ],
        .environment: [
            "평소보다 작은 그릇에 음식 담기",
            "환경 습관 2",
            "환경 습관 3",
            "환경 습관 4",
            "환경 습관 5",
            "환경 습관 6",
            "환경 습관 7",
            "환경 습관 8",
            "환경 습관 9",
            "환경 습관 10"
        ]
    ]

    // 날짜 기준 그날의 습관 카드 3개 (운동/식욕/환경 각 1개)
    static func todaysHabits(for date: Date = .now) -> [Habit] {
        let dayNumber = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let number = dayNumber % habitsPerCategory + 1
        return HabitCategory.allCases.enumerated().map { index, category in
            Habit(
                id: index,
                title: category.title,
                iconName: category.iconName,
                text: texts[category]?[number - 1] ?? "",
                imageName: "rutine_\(category.rawValue)_\(number)"
            )
        }
    }
}
