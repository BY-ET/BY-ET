import Foundation

/// 고양이 유형 8종
enum CatType: String, CaseIterable {
    case type1 = "에너지가 넘쳐흐르는 파워 고양이"
    case type2 = "존재감 뚜렷한 인싸 고양이"
    case type3 = "자기관리의 정석 갓생 고양이"
    case type4 = "묵묵하게 달리는 열정 고양이"
    case type5 = "안락한 삶을 누리는 귀족 고양이"
    case type6 = "태어난 김에 사는 하루살이 고양이"
    case type7 = "숨만 쉬어도 행복한 집수니 고양이"
    case type8 = "매일이 고달픈 생존형 고양이"
}

/// 기준별 O/X 판정 결과
struct CategoryJudgement {
    let category: QuestionCategory
    let score: Int      // 0~5
    let isPositive: Bool // 3점 이상 -> true(O), 2점 이하 -> false(X)
}

struct SurveyResultCalculator {

    /// 답변 배열을 받아서 최종 고양이 유형을 계산
    static func calculate(from answers: [UserAnswer]) -> (catType: CatType, judgements: [CategoryJudgement]) {
        let judgements = QuestionCategory.allCases.map { category -> CategoryJudgement in
            let score = answers
                .filter { $0.category == category }
                .reduce(0) { $0 + $1.selectedOption.score }
            return CategoryJudgement(category: category, score: score, isPositive: score >= 3)
        }

        let exercise = judgements.first { $0.category == .exercise }?.isPositive ?? false
        let appetite = judgements.first { $0.category == .appetite }?.isPositive ?? false
        let environment = judgements.first { $0.category == .environment }?.isPositive ?? false

        let catType: CatType
        switch (exercise, appetite, environment) {
        case (true, true, true):    catType = .type1
        case (true, true, false):   catType = .type2
        case (true, false, true):   catType = .type3
        case (true, false, false):  catType = .type4
        case (false, true, true):   catType = .type5
        case (false, true, false):  catType = .type6
        case (false, false, true):  catType = .type7
        case (false, false, false): catType = .type8
        }

        return (catType, judgements)
    }
}
