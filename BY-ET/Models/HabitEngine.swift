import Foundation

// 규칙 기반 습관 매칭 엔진 (AI 없음 - 같은 입력이면 항상 같은 결과)
//
// 카테고리(운동/식단/환경)마다 아래 fallback 우선순위를 위에서부터 평가해
// 후보가 나오는 첫 티어에서 1개를 뽑는다:
//   1. 정확 매칭: 유형 context 일치 + 목표 일치 + 허용 난이도 이내
//   2. context 완화: context=무관 + 목표 일치
//   3. 목표 유지 난이도 완화: 선택 목표 습관이 허용 난이도 안에 없으면 +1까지 허용
//      (예: '술 줄이기'의 유일한 습관 D09는 난이도 2라 1~2주차에도 이 티어로 등장)
//   4. 인접 목표 대체: 인접 목표 + (context 일치 또는 무관)
//   5. 유형 우선 목표: 유형매핑 시트의 추천 우선 목표
//   6. 난이도 완화: 허용 난이도 +1로 1~5 재시도
//   7. 중복 회피 해제: 최근 3일 중복 제외를 풀고 1~6 재시도
//   8. 안전망: context=무관 최저 난이도 (모든 카테고리에 존재하므로 항상 성공)
// 같은 티어에 후보가 여럿이면 가장 오래전에 배정된 습관 우선, 동률이면 코드 오름차순.
enum HabitEngine {

    static let recentAvoidDays = 3
    // 지난주 완료율이 이 값 이상인 카테고리는 난이도 상한 +1 (커브 최대 상한까지)
    static let difficultyUpRate = 0.7

    // MARK: - 오늘의 습관 (배정 저장 포함)

    // 오늘의 습관 3개 (운동/식단/환경 각 1개).
    // 같은 날 다시 부르면 저장된 배정을 그대로 반환하고,
    // 새 날짜면 어제까지의 미완료 습관을 스킵으로 마감한 뒤 새로 선택해 저장한다.
    static func todaysHabits(for date: Date = .now) -> [Habit] {
        let dateID = HabitProgressStore.todayID(for: date)
        if let saved = HabitStore.assignment(for: dateID) {
            return makeCards(codes: saved.codes)
        }

        HabitStore.closeOutPendingDays(before: dateID)

        let profile = HabitStore.profile ?? .fallback()
        let codes = select(profile: profile,
                           date: date,
                           history: HabitStore.assignments,
                           logs: HabitStore.logs)
        HabitStore.saveAssignment(DailyAssignment(dateID: dateID, date: date, codes: codes))
        return makeCards(codes: codes)
    }

    private static func makeCards(codes: [String]) -> [Habit] {
        codes.enumerated().compactMap { index, code in
            guard let record = HabitDatabase.habit(code: code) else { return nil }
            return Habit(
                id: index,
                code: record.code,
                title: record.category.title,
                iconName: record.category.iconName,
                text: record.text,
                imageName: record.imageName
            )
        }
    }

    // MARK: - 선택 파이프라인 (순수 함수 - 테스트 가능)

    // 카테고리별 1개씩 선택해 HabitCategory.allCases 순서(운동/식단/환경)로 반환
    static func select(profile: HabitUserProfile,
                       date: Date,
                       history: [DailyAssignment],
                       logs: [CompletionLog]) -> [String] {
        let week = profile.week(on: date)
        let recentCodes = recentCodes(in: history, days: recentAvoidDays, before: date)

        return HabitCategory.allCases.map { category in
            pick(category: category,
                 profile: profile,
                 week: week,
                 recentCodes: recentCodes,
                 history: history,
                 logs: logs).code
        }
    }

    static func pick(category: HabitCategory,
                     profile: HabitUserProfile,
                     week: Int,
                     recentCodes: Set<String>,
                     history: [DailyAssignment],
                     logs: [CompletionLog]) -> HabitRecord {
        let mapping = TypeMapping.mapping(for: profile.catType)
        let caps = DifficultyCurve.caps(week: week, totalWeeks: profile.totalWeeks)

        // 허용 난이도 상한: 주차 커브와 유형 시작값 중 높은 쪽 (파워/열정 고양이는 1주차부터 2)
        var cap = max(caps.base, mapping.startDifficulty)
        // 지난주 완료율이 높은 카테고리만 상한 +1 (커브의 최대 상한까지)
        if week > 1,
           completionRate(category: category, week: week - 1, profile: profile, history: history, logs: logs) >= difficultyUpRate {
            cap = max(cap, min(cap + 1, caps.max))
        }

        let pool = HabitDatabase.habits(in: category)

        // 유형 context와 일치 (무관 습관 제외)
        let exactContext: (HabitContext) -> Bool = { $0.matches(mapping.context) }
        // 무관 습관만
        let anyContext: (HabitContext) -> Bool = { $0 == .any }
        // 유형 context 일치 또는 무관
        let exactOrAnyContext: (HabitContext) -> Bool = { $0.matches(mapping.context) || $0 == .any }

        func candidates(goal: TargetGoal, context: (HabitContext) -> Bool, cap: Int, avoidRecent: Bool) -> [HabitRecord] {
            pool.filter { habit in
                habit.goal == goal
                    && habit.difficulty <= cap
                    && context(habit.context)
                    && (!avoidRecent || !recentCodes.contains(habit.code))
                    // "먹지 않음" 체크된 끼니에만 걸린 습관은 그날 후보에서 제외
                    && habit.isAvailable(meals: profile.meals)
            }
        }

        // 티어 1~5를 주어진 난이도/중복 조건으로 생성
        func tiers(cap: Int, avoidRecent: Bool) -> [[HabitRecord]] {
            var result: [[HabitRecord]] = [
                candidates(goal: profile.goal, context: exactContext, cap: cap, avoidRecent: avoidRecent),
                candidates(goal: profile.goal, context: anyContext, cap: cap, avoidRecent: avoidRecent),
                // 선택 목표를 인접 목표로 대체하기 전에 난이도 완화를 먼저 시도 (목표 충실도 우선)
                candidates(goal: profile.goal, context: exactOrAnyContext, cap: min(cap + 1, 3), avoidRecent: avoidRecent)
            ]
            for adjacent in profile.goal.adjacentGoals {
                result.append(candidates(goal: adjacent, context: exactOrAnyContext, cap: cap, avoidRecent: avoidRecent))
            }
            result.append(candidates(goal: mapping.priorityGoal, context: exactOrAnyContext, cap: cap, avoidRecent: avoidRecent))
            return result
        }

        var allTiers = tiers(cap: cap, avoidRecent: true)                       // 티어 1~5
        allTiers += tiers(cap: min(cap + 1, 3), avoidRecent: true)              // 티어 6: 난이도 완화
        allTiers += tiers(cap: cap, avoidRecent: false)                         // 티어 7: 중복 회피 해제
        allTiers += tiers(cap: min(cap + 1, 3), avoidRecent: false)

        for tier in allTiers {
            if let chosen = choose(from: tier, history: history) {
                return chosen
            }
        }

        // 티어 8 안전망: context=무관 최저 난이도 (D02, E01, X05 등이 항상 존재)
        let safety = pool.filter { $0.context == .any && $0.isAvailable(meals: profile.meals) }
            .sorted { ($0.difficulty, $0.code) < ($1.difficulty, $1.code) }
        if let chosen = choose(from: safety, history: history) {
            return chosen
        }
        // 모든 끼니를 건너뛰는 극단적인 경우에도 빈손이 되지 않도록 끼니 조건 없이 재시도
        let lastResort = pool.sorted { ($0.difficulty, $0.code) < ($1.difficulty, $1.code) }
        return choose(from: lastResort, history: history) ?? pool[0]
    }

    // 같은 티어 안에서의 결정적 선택: 배정된 지 가장 오래된 습관 우선, 동률이면 코드 오름차순
    private static func choose(from candidates: [HabitRecord], history: [DailyAssignment]) -> HabitRecord? {
        guard !candidates.isEmpty else { return nil }
        var lastAssigned: [String: Int] = [:]
        for (index, assignment) in history.enumerated() {
            for code in assignment.codes {
                lastAssigned[code] = index
            }
        }
        return candidates.min {
            (lastAssigned[$0.code] ?? -1, $0.code) < (lastAssigned[$1.code] ?? -1, $1.code)
        }
    }

    // 최근 N일 동안 배정됐던 습관 코드 (중복 회피용)
    static func recentCodes(in history: [DailyAssignment], days: Int, before date: Date) -> Set<String> {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -days, to: calendar.startOfDay(for: date)) else {
            return []
        }
        return Set(history.filter { $0.date >= cutoff && $0.date < date }.flatMap(\.codes))
    }

    // MARK: - 완료율 (난이도 조정의 근거)

    // 해당 주차의 카테고리 완료율 = 완료 기록 수 / 배정 수 (배정이 없으면 0)
    static func completionRate(category: HabitCategory,
                               week: Int,
                               profile: HabitUserProfile,
                               history: [DailyAssignment],
                               logs: [CompletionLog]) -> Double {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: profile.startDate)
        guard let weekStart = calendar.date(byAdding: .day, value: (week - 1) * 7, to: start),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return 0 }

        let assigned = history
            .filter { $0.date >= weekStart && $0.date < weekEnd }
            .flatMap { assignment in
                assignment.codes
                    .filter { HabitDatabase.habit(code: $0)?.category == category }
                    .map { "\(assignment.dateID)|\($0)" }
            }
        guard !assigned.isEmpty else { return 0 }

        let completedKeys = Set(logs.filter { $0.status == .completed }.map { "\($0.dateID)|\($0.code)" })
        let completed = assigned.filter { completedKeys.contains($0) }.count
        return Double(completed) / Double(assigned.count)
    }

    // MARK: - 알림 시각 계산 (트리거 기준표 시트)

    // 식사전/외출전/귀가: 기준 시각 30분 전
    static let reminderLeadMinutes = -30
    // 상시고정: 14시 (외출~귀가 사이)
    static let fixedDailyHour = 14
    // 저녁: 저녁 20시
    static let eveningHour = 20

    // 습관의 알림 트리거(NotificationRule)와 프로필의 끼니/외출 시간으로 그날의 알림 시각들을 계산한다.
    // 식사 연동 습관은 먹는 끼니마다 1개씩 반환 (달성할 때까지 끼니 시간대에 계속 알림),
    // "먹지 않음" 체크된 끼니의 알림은 생략된다. 그 외 규칙은 최대 1개.
    static func notificationDates(for habit: HabitRecord, profile: HabitUserProfile, on date: Date = .now) -> [Date] {
        let calendar = Calendar.current

        func at(hour: Int, minute: Int, offsetMinutes: Int = 0) -> Date? {
            guard let base = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) else { return nil }
            return calendar.date(byAdding: .minute, value: offsetMinutes, to: base)
        }

        // 요일에 맞는 외출/귀가 시간 (평일/주말)
        let isWeekend = calendar.isDateInWeekend(date)
        let outing = profile.outings.first { isWeekend ? $0.label == "주말" : $0.label == "평일" } ?? profile.outings.first

        switch habit.notification {
        case .meal(let slots):
            return slots.compactMap { slot in
                guard let meal = profile.meals.first(where: { $0.name == slot.rawValue && !$0.isSkipped }) else { return nil }
                return at(hour: meal.hour, minute: meal.minute, offsetMinutes: reminderLeadMinutes)
            }
        case .beforeOuting:
            guard let outing else { return [] }
            return [at(hour: outing.departureHour, minute: outing.departureMinute, offsetMinutes: reminderLeadMinutes)].compactMap { $0 }
        case .beforeArrival:
            guard let outing else { return [] }
            return [at(hour: outing.arrivalHour, minute: outing.arrivalMinute, offsetMinutes: reminderLeadMinutes)].compactMap { $0 }
        case .fixedDaily:
            return [at(hour: fixedDailyHour, minute: 0)].compactMap { $0 }
        case .evening:
            return [at(hour: eveningHour, minute: 0)].compactMap { $0 }
        }
    }
}
