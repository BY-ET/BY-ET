import Foundation

/// 식사 시간 설정
struct MealTime: Identifiable {
    let id = UUID()
    let name: String
    var time: Date
    var isSkipped: Bool = false
}

/// 외출 시간 설정 (나가는 시간 / 돌아오는 시간)
struct OutingTime: Identifiable {
    let id = UUID()
    var label: String
    var departure: Date
    var arrival: Date
    var isCustom: Bool = false
}

struct GoalOptionRepository {
    static let habitOptions = ["물 자주 마시기", "과식하지 않기", "술 줄이기", "외식 / 배달음식 줄이기"]
    static let periodOptions = ["2주 뒤", "4주 뒤 (한 달)", "6주 뒤"]

    static let defaultMealTimes: [MealTime] = [
        MealTime(name: "아침", time: .todayAt(hour: 9, minute: 0)),
        MealTime(name: "점심", time: .todayAt(hour: 12, minute: 30)),
        MealTime(name: "저녁", time: .todayAt(hour: 19, minute: 0))
    ]

    static let defaultOutingTimes: [OutingTime] = [
        OutingTime(label: "평일", departure: .todayAt(hour: 9, minute: 0), arrival: .todayAt(hour: 20, minute: 0)),
        OutingTime(label: "주말", departure: .todayAt(hour: 12, minute: 30), arrival: .todayAt(hour: 18, minute: 0))
    ]
}

extension Date {
    /// 오늘 날짜 기준으로 시/분만 지정한 Date 생성
    static func todayAt(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
