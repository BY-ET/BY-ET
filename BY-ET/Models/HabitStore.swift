import Foundation

// MARK: - 유저 프로필 (유형 + 목표 + 기간 + 시간, 목표 설정 완료 시 저장)

struct HabitUserProfile: Codable {
    var catTypeRaw: String
    var goalRaw: String
    var totalWeeks: Int
    var startDate: Date
    var meals: [MealTimeSnapshot]
    var outings: [OutingTimeSnapshot]

    var catType: CatType { CatType(rawValue: catTypeRaw) ?? .type4 }
    var goal: TargetGoal { TargetGoal(rawValue: goalRaw) ?? .overeating }

    // 시작일이 속한 주(일요일 시작)를 1주차로, 일요일 0시마다 주차가 올라감
    // (주간 달성률과 같은 기준, 목표 기간을 넘으면 마지막 주차로 고정)
    func week(on date: Date = .now) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        let startWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
        let currentWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
        let weeks = calendar.dateComponents([.weekOfYear], from: startWeek, to: currentWeek).weekOfYear ?? 0
        return min(max(weeks + 1, 1), totalWeeks)
    }

    // 프로필이 없을 때(기존 사용자, 프리뷰) 저장된 유형만으로 만드는 기본 프로필
    static func fallback() -> HabitUserProfile {
        HabitUserProfile(
            catTypeRaw: UserDefaults.standard.string(forKey: "catTypeRaw") ?? CatType.type4.rawValue,
            goalRaw: TargetGoal.overeating.rawValue,
            totalWeeks: 4,
            startDate: Calendar.current.startOfDay(for: .now),
            meals: GoalOptionRepository.defaultMealTimes.map(MealTimeSnapshot.init),
            outings: GoalOptionRepository.defaultOutingTimes.map(OutingTimeSnapshot.init)
        )
    }
}

struct MealTimeSnapshot: Codable {
    let name: String
    let hour: Int
    let minute: Int
    let isSkipped: Bool

    init(from meal: MealTime) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: meal.time)
        name = meal.name
        hour = components.hour ?? 0
        minute = components.minute ?? 0
        isSkipped = meal.isSkipped
    }
}

struct OutingTimeSnapshot: Codable {
    let label: String
    let departureHour: Int
    let departureMinute: Int
    let arrivalHour: Int
    let arrivalMinute: Int

    init(from outing: OutingTime) {
        let calendar = Calendar.current
        let departure = calendar.dateComponents([.hour, .minute], from: outing.departure)
        let arrival = calendar.dateComponents([.hour, .minute], from: outing.arrival)
        label = outing.label
        departureHour = departure.hour ?? 0
        departureMinute = departure.minute ?? 0
        arrivalHour = arrival.hour ?? 0
        arrivalMinute = arrival.minute ?? 0
    }
}

// MARK: - 하루 배정 기록 (daily_assignments) - 중복 회피·완료율 계산의 근거

struct DailyAssignment: Codable {
    let dateID: String    // HabitProgressStore.todayID 형식 (예: "2026-8-16")
    let date: Date
    let codes: [String]   // HabitCategory.allCases 순서 (운동/식단/환경)
}

// MARK: - 완료 기록 (completion_logs)

struct CompletionLog: Codable {
    enum Status: String, Codable {
        case completed
        case skipped
    }

    let dateID: String
    let code: String
    let status: Status
}

// MARK: - 저장소 (UserDefaults에 JSON으로 저장)

enum HabitStore {
    private static let profileKey = "habitUserProfile"
    private static let assignmentsKey = "habitDailyAssignments"
    private static let logsKey = "habitCompletionLogs"
    // 완료율 계산에 필요한 최근 기록만 유지
    private static let keptDays = 90

    // MARK: 프로필

    static var profile: HabitUserProfile? {
        load(profileKey)
    }

    static func saveProfile(_ profile: HabitUserProfile) {
        save(profile, key: profileKey)
    }

    // MARK: 배정 기록

    static var assignments: [DailyAssignment] {
        load(assignmentsKey) ?? []
    }

    static func assignment(for dateID: String) -> DailyAssignment? {
        assignments.first { $0.dateID == dateID }
    }

    static func saveAssignment(_ assignment: DailyAssignment) {
        var records = assignments.filter { $0.dateID != assignment.dateID }
        records.append(assignment)
        records.sort { $0.date < $1.date }
        if records.count > keptDays {
            records.removeFirst(records.count - keptDays)
        }
        save(records, key: assignmentsKey)
    }

    // MARK: 완료/스킵 기록

    static var logs: [CompletionLog] {
        load(logsKey) ?? []
    }

    static func log(code: String, dateID: String, status: CompletionLog.Status) {
        var records = logs.filter { !($0.dateID == dateID && $0.code == code) }
        records.append(CompletionLog(dateID: dateID, code: code, status: status))
        save(records, key: logsKey)
    }

    // 지나간 날의 배정 중 완료 기록이 없는 습관을 스킵으로 마감
    static func closeOutPendingDays(before dateID: String) {
        var records = logs
        let loggedKeys = Set(records.map { "\($0.dateID)|\($0.code)" })
        for assignment in assignments where assignment.dateID != dateID {
            for code in assignment.codes where !loggedKeys.contains("\(assignment.dateID)|\(code)") {
                records.append(CompletionLog(dateID: assignment.dateID, code: code, status: .skipped))
            }
        }
        save(records, key: logsKey)
    }

    // MARK: JSON 직렬화

    private static func load<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
