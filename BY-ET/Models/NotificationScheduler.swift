import Foundation
import UserNotifications

// 오늘의 습관 3개에 대한 로컬 알림 스케줄러
// - 알림 시각은 HabitEngine.notificationDates가 계산 (알림 규칙 + 프로필의 끼니/외출 시간)
// - 식사 연동 습관은 먹는 끼니마다 알림이 걸리고, 완료하면 남은 알림을 취소한다
//   ("달성할 때까지 기록한 시간대에 계속 알림")
enum NotificationScheduler {
    private static let identifierPrefix = "habit"
    // 습관 1개가 가질 수 있는 최대 알림 수 (식사 연동: 아침/점심/저녁)
    private static let maxNotificationsPerHabit = MealSlot.allCases.count

    // 알림 권한 요청 (이미 응답한 경우 시스템이 다시 묻지 않음)
    static func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // 오늘의 습관 알림을 다시 스케줄 (기존 습관 알림을 모두 제거한 뒤 등록)
    // completedCodes에 있는 습관과 이미 지난 시각의 알림은 걸지 않는다
    static func scheduleToday(codes: [String], completedCodes: Set<String> = [], on date: Date = .now) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            let habitIDs = pending.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
            center.removePendingNotificationRequests(withIdentifiers: habitIDs)

            let profile = HabitStore.profile ?? .fallback()
            for code in codes where !completedCodes.contains(code) {
                guard let habit = HabitDatabase.habit(code: code) else { continue }
                let dates = HabitEngine.notificationDates(for: habit, profile: profile, on: date)
                for (index, fireDate) in dates.enumerated() where fireDate > Date.now {
                    center.add(request(for: habit, fireDate: fireDate, index: index))
                }
            }
        }
    }

    // 습관 완료 시 남은 알림 취소 (식사 연동 습관의 반복 알림 중단)
    static func cancelNotifications(code: String) {
        let identifiers = (0..<maxNotificationsPerHabit).map { identifier(code: code, index: $0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private static func identifier(code: String, index: Int) -> String {
        "\(identifierPrefix)|\(code)|\(index)"
    }

    private static func request(for habit: HabitRecord, fireDate: Date, index: Int) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "오늘의 \(habit.category.title) 습관"
        content.body = habit.text.replacingOccurrences(of: "\n", with: " ")
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: identifier(code: habit.code, index: index),
                                     content: content,
                                     trigger: trigger)
    }
}
