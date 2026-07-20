import Foundation

// 주간/요일별 습관 달성 기록 헬퍼 (RutineView가 기록, HomeView가 표시)
// 주는 일요일 0시에 바뀜
enum HabitProgressStore {
    static let cardsPerDay = 3
    static let cardsPerWeek = 21

    // 일요일을 한 주의 시작으로 쓰는 캘린더
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        return calendar
    }

    // 현재 주 식별자 (예: "2026-30") - 저장된 값과 다르면 주가 바뀐 것
    static func currentWeekID(for date: Date = .now) -> String {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return "\(components.yearForWeekOfYear ?? 0)-\(components.weekOfYear ?? 0)"
    }

    // 오늘 요일 인덱스 (일=0 ~ 토=6)
    static func todayIndex(for date: Date = .now) -> Int {
        calendar.component(.weekday, from: date) - 1
    }

    // 오늘 날짜 식별자 (예: "2026-7-20") - 저장된 값과 다르면 날짜가 바뀐 것
    static func todayID(for date: Date = .now) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    // AppStorage에 "0,0,0,0,0,0,0" 형태로 저장된 요일별 완료 개수 변환
    static func parseDailyCounts(_ raw: String) -> [Int] {
        let counts = raw.split(separator: ",").compactMap { Int($0) }
        return counts.count == 7 ? counts : Array(repeating: 0, count: 7)
    }

    static func encodeDailyCounts(_ counts: [Int]) -> String {
        counts.map(String.init).joined(separator: ",")
    }

    // AppStorage에 "0,1,0" 형태로 저장된 카드 상태(뒤집힘/완료) 변환
    static func parseFlags(_ raw: String) -> [Bool] {
        let flags = raw.split(separator: ",").map { $0 == "1" }
        return flags.count == 3 ? flags : Array(repeating: false, count: 3)
    }

    static func encodeFlags(_ flags: [Bool]) -> String {
        flags.map { $0 ? "1" : "0" }.joined(separator: ",")
    }
}
