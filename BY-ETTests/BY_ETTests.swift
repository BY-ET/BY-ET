//
//  BY_ETTests.swift
//  BY-ETTests
//
//  Created by siye on 6/2/26.
//

import Foundation
import Testing
@testable import BY_ET

struct HabitEngineTests {

    private let calendar = Calendar.current

    private func makeProfile(catType: CatType = .type8,
                             goal: TargetGoal = .water,
                             weeks: Int = 2,
                             startDate: Date = .now) -> HabitUserProfile {
        HabitUserProfile(
            catTypeRaw: catType.rawValue,
            goalRaw: goal.rawValue,
            totalWeeks: weeks,
            startDate: calendar.startOfDay(for: startDate),
            meals: [],
            outings: []
        )
    }

    @Test func 카테고리별로_하나씩_운동_식단_환경_순서로_선택() {
        let codes = HabitEngine.select(profile: makeProfile(), date: .now, history: [], logs: [])
        #expect(codes.count == 3)
        #expect(codes[0].hasPrefix("X"))
        #expect(codes[1].hasPrefix("D"))
        #expect(codes[2].hasPrefix("E"))
    }

    // 선택 목표의 습관이 허용 난이도 안에 없으면 인접 목표보다 난이도 완화를 먼저 시도 (목표 충실도 우선)
    // 물 목표: 식단은 난이도 2인 D01이 완화로 등장, 환경/운동은 일치 습관이 0개라 인접 목표(과식)로 대체
    @Test func 후보_부족시_난이도완화_후_인접목표로_대체() {
        let codes = HabitEngine.select(profile: makeProfile(goal: .water), date: .now, history: [], logs: [])
        #expect(codes == ["X02", "D01", "E01"])
    }

    // 열정 고양이(시작난이도 2)는 1주차 커브(난이도 1)보다 시작값이 우선 → 난이도 2 습관 등장
    @Test func 유형_시작난이도가_주차커브보다_우선() {
        let profile = makeProfile(catType: .type4, goal: .delivery, weeks: 4)
        let codes = HabitEngine.select(profile: profile, date: .now, history: [], logs: [])
        // 운동 X01(난이도2, 사무실), 식단은 일치 습관 0개라 인접 목표 D02, 환경 E08(난이도2)
        #expect(codes == ["X01", "D02", "E08"])
    }

    // '술 줄이기'의 유일한 습관 D09(난이도 2)는 1주차에도 식단 카드로 나와야 함
    @Test func 술줄이기는_1주차에도_D09_등장() {
        let profile = makeProfile(catType: .type2, goal: .alcohol, weeks: 4)
        let codes = HabitEngine.select(profile: profile, date: .now, history: [], logs: [])
        #expect(codes[1] == "D09")
    }

    @Test func 최근_3일_배정_습관은_회피() {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: .now)!
        let history = [DailyAssignment(dateID: "yesterday", date: yesterday, codes: ["X02", "D01", "E01"])]
        let codes = HabitEngine.select(profile: makeProfile(goal: .water), date: .now, history: history, logs: [])
        #expect(Set(codes).isDisjoint(with: ["X02", "D01", "E01"]))
        // 식단은 물 목표의 남은 습관 D05, 환경/운동은 인접 목표의 다음 후보
        #expect(codes == ["X05", "D05", "E07"])
    }

    @Test func 초반_주차는_난이도_1만_허용() {
        // 과식 목표는 난이도 1 후보가 충분해 완화 없이 전부 난이도 1이어야 함
        let codes = HabitEngine.select(profile: makeProfile(goal: .overeating, weeks: 2), date: .now, history: [], logs: [])
        for code in codes {
            #expect(HabitDatabase.habit(code: code)!.difficulty == 1)
        }
    }

    @Test func 완료율_계산() {
        let start = calendar.date(byAdding: .day, value: -28, to: calendar.startOfDay(for: .now))!
        let profile = makeProfile(goal: .overeating, weeks: 6, startDate: start)
        // 4주차(22~28일차) 이틀간 식단 습관 배정, 하나만 완료 → 50%
        let day1 = calendar.date(byAdding: .day, value: 21, to: start)!
        let day2 = calendar.date(byAdding: .day, value: 22, to: start)!
        let history = [
            DailyAssignment(dateID: "d1", date: day1, codes: ["X05", "D02", "E01"]),
            DailyAssignment(dateID: "d2", date: day2, codes: ["X06", "D03", "E07"])
        ]
        let logs = [CompletionLog(dateID: "d1", code: "D02", status: .completed)]
        let rate = HabitEngine.completionRate(category: .eat, week: 4, profile: profile, history: history, logs: logs)
        #expect(rate == 0.5)
    }

    // 규칙 기반이므로 같은 입력이면 항상 같은 결과
    @Test func 같은_입력이면_같은_결과() {
        let profile = makeProfile(catType: .type6, goal: .delivery, weeks: 4)
        let first = HabitEngine.select(profile: profile, date: .now, history: [], logs: [])
        let second = HabitEngine.select(profile: profile, date: .now, history: [], logs: [])
        #expect(first == second)
    }
}
