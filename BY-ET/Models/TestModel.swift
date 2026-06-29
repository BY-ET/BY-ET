import Foundation

/// 선택지 하나
struct QuestionOption: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let value: String
    let score: Int   // A=1점, B=0점
}

/// 기준 카테고리 (운동 / 식욕 / 환경)
enum QuestionCategory: String, Codable, CaseIterable {
    case exercise = "운동"
    case appetite = "식욕"
    case environment = "환경"
}

struct Question: Identifiable, Codable {
    let id: String
    let order: Int
    let title: String
    let category: QuestionCategory
    let options: [QuestionOption]
}

struct UserAnswer: Codable, Identifiable {
    var id: String { questionId }
    let questionId: String
    let category: QuestionCategory
    let selectedOption: QuestionOption
}

struct QuestionRepository {
    static let questions: [Question] = [
        // 기준 1: 운동 (Q1~Q5)
        Question(id: "Q1", order: 1,
            title: "오랜만에 찾아온 휴일, 당신의 모습과 더 가까운 것은?",
            category: .exercise,
            options: [
                QuestionOption(id: "Q1_A", text: "피로를 날리기 위해 운동이나 산책을 하거나, 약속을 위해 나간다", value: "active", score: 1),
                QuestionOption(id: "Q1_B", text: "침대와 한 몸이 되어 밀린 드라마를 보거나, 늦잠을 자며 푹 쉰다", value: "rest", score: 0)
            ]
        ),
        Question(id: "Q2", order: 2,
            title: "건물 2층에 올라가야 할 때 당신의 선택은?",
            category: .exercise,
            options: [
                QuestionOption(id: "Q2_A", text: "건강을 생각해 웬만하면 계단을 이용한다", value: "stairs", score: 1),
                QuestionOption(id: "Q2_B", text: "무조건 엘리베이터를 기다린다", value: "elevator", score: 0)
            ]
        ),
        Question(id: "Q3", order: 3,
            title: "10분 정도 걸어가야 하는 가까운 거리라면?",
            category: .exercise,
            options: [
                QuestionOption(id: "Q3_A", text: "날씨가 나쁘지 않다면, 음악을 들으며 걷는 것을 선택한다", value: "walk", score: 1),
                QuestionOption(id: "Q3_B", text: "5분만 걸어도 되는 거리라도 버스나 택시를 먼저 생각한다", value: "ride", score: 0)
            ]
        ),
        Question(id: "Q4", order: 4,
            title: "집에서 혼자 식사를 마친 직후, 당신의 모습은?",
            category: .exercise,
            options: [
                QuestionOption(id: "Q4_A", text: "설거지가 쌓이는 건 못 본다. 바로 설거지와 뒷정리를 한다", value: "immediate", score: 1),
                QuestionOption(id: "Q4_B", text: "일단 배부르고 나른하니, 좀 쉬었다가 나중에 한다", value: "delayed", score: 0)
            ]
        ),
        Question(id: "Q5", order: 5,
            title: "새로운 모임에 들어갔다. 당신이 선택한 모임의 특성은?",
            category: .exercise,
            options: [
                QuestionOption(id: "Q5_A", text: "배드민턴, 축구, 볼링 등 활동적인 모임이다", value: "active_group", score: 1),
                QuestionOption(id: "Q5_B", text: "독서, 스터디, 다도 등 정적인 모임이다", value: "static_group", score: 0)
            ]
        ),

        // 기준 2: 식욕 (Q6~Q10)
        Question(id: "Q6", order: 6,
            title: "스트레스를 받는 상황에서 당신의 행동은?",
            category: .appetite,
            options: [
                QuestionOption(id: "Q6_A", text: "이럴 땐 먹어야 해. 매운 떡볶이나 달콤한 디저트가 가장 먼저 생각난다", value: "stress_eat", score: 1),
                QuestionOption(id: "Q6_B", text: "속이 더부룩하고 입맛이 뚝 떨어진다. 밥때를 거르기도 한다", value: "stress_skip", score: 0)
            ]
        ),
        Question(id: "Q7", order: 7,
            title: "배가 부를 때, 맛있는 음식이 눈앞에 있다면?",
            category: .appetite,
            options: [
                QuestionOption(id: "Q7_A", text: "배불러도 이건 못 참지. 일단 한입이라도 더 먹는 편이다", value: "overeat", score: 1),
                QuestionOption(id: "Q7_B", text: "아무리 맛있는 음식이라도 배가 부르면 숟가락을 딱 내려놓는다", value: "stop", score: 0)
            ]
        ),
        Question(id: "Q8", order: 8,
            title: "친구와의 저녁 약속에서 맛있는 치킨 한 조각이 남았다. 당신의 선택은?",
            category: .appetite,
            options: [
                QuestionOption(id: "Q8_A", text: "혹시 이거 내가 먹어도 돼? 라고 물어보고 먹는다", value: "ask_eat", score: 1),
                QuestionOption(id: "Q8_B", text: "이거 하나 누가 먹어라 하고 양보한다", value: "yield", score: 0)
            ]
        ),
        Question(id: "Q9", order: 9,
            title: "식사를 배부르게 마친 직후, 당신의 다음 행동은?",
            category: .appetite,
            options: [
                QuestionOption(id: "Q9_A", text: "디저트 배는 따로 있지. 습관적으로 달콤한 케이크나 아이스크림을 찾는다", value: "dessert", score: 1),
                QuestionOption(id: "Q9_B", text: "배부르다 끝. 입가심으로 마실 물이나 깔끔한 차 한 잔이면 충분하다", value: "tea_water", score: 0)
            ]
        ),
        Question(id: "Q10", order: 10,
            title: "지인과의 약속으로 술집에 갔다. 안주가 끊임없이 나올 때 당신의 행동은?",
            category: .appetite,
            options: [
                QuestionOption(id: "Q10_A", text: "술만 먹으면, 안주가 무한대로 들어간다. 주는 안주를 빠짐없이 먹는다", value: "eat_all", score: 1),
                QuestionOption(id: "Q10_B", text: "안주가 딱히 땡기지 않는다. 몇 개 집어먹다 끝난다", value: "not_tempted", score: 0)
            ]
        ),

        // 기준 3: 환경 (Q11~Q15)
        Question(id: "Q11", order: 11,
            title: "저녁 약속이나 회식에서 다이어트 중이라고 말할 때, 주위의 반응은?",
            category: .environment,
            options: [
                QuestionOption(id: "Q11_A", text: "샐러드 시키거나 적당히 먹어~ 라며 배려해주는 편이다", value: "supportive", score: 1),
                QuestionOption(id: "Q11_B", text: "오늘만 먹어, 다이어트 왜 해? 라며 각종 안주와 술을 권하는 분위기다", value: "unsupportive", score: 0)
            ]
        ),
        Question(id: "Q12", order: 12,
            title: "당신의 집 냉장고(또는 찬장)에 더 가까운 것은?",
            category: .environment,
            options: [
                QuestionOption(id: "Q12_A", text: "과일, 채소, 견과류, 제로 음료 등 건강한 옵션이 항상 준비되어 있다", value: "healthy_stock", score: 1),
                QuestionOption(id: "Q12_B", text: "라면, 과자, 빵, 맥주 등 유혹적인 음식들이 눈에 잘 띄게 놓여 있다", value: "junk_stock", score: 0)
            ]
        ),
        Question(id: "Q13", order: 13,
            title: "퇴근 후 당신의 일상은?",
            category: .environment,
            options: [
                QuestionOption(id: "Q13_A", text: "일정한 시간에 퇴근 후 운동을 하거나, 직접 저녁을 차려 먹는 나만의 루틴이 있다", value: "routine", score: 1),
                QuestionOption(id: "Q13_B", text: "잦은 야근 혹은 과도한 업무로 녹초가 되어, 끼니를 대충 해결하고 쓰러져 자기 바쁘다", value: "exhausted", score: 0)
            ]
        ),
        Question(id: "Q14", order: 14,
            title: "함께 사는 가족이나 룸메이트의 저녁 식사 패턴은?",
            category: .environment,
            options: [
                QuestionOption(id: "Q14_A", text: "집에서 규칙적인 시간에 먹거나, 균형 잡힌 식사를 하는 편이다", value: "regular_household", score: 1),
                QuestionOption(id: "Q14_B", text: "배달 음식을 시키는 횟수가 잦고, 늦은 밤 야식을 즐기는 편이다", value: "delivery_household", score: 0)
            ]
        ),
        Question(id: "Q15", order: 15,
            title: "야근 혹은 시험공부로 늦게까지 남아있을 때, 함께하는 지인들의 분위기는?",
            category: .environment,
            options: [
                QuestionOption(id: "Q15_A", text: "얼른 끝내고 가자. 각자 조용히 마무리하거나, 건강한 음료를 마신다", value: "quiet_finish", score: 1),
                QuestionOption(id: "Q15_B", text: "출출하지? 누군가 꼭 야식을 제안하고, 다 같이 편의점을 가거나 배달음식을 시켜 먹는다", value: "suggest_snack", score: 0)
            ]
        )
    ]
}
