import Foundation

// MARK: - 습관 목표 (목표 설정 Q1 선택지와 매핑)

enum TargetGoal: String, Codable, CaseIterable {
    case water = "물 자주 마시기"
    case overeating = "과식하지 않기"
    case alcohol = "술 줄이기"
    case delivery = "외식/배달음식 줄이기"

    // 후보 부족 시 대체할 인접 목표 (앞이 먼저 시도됨)
    var adjacentGoals: [TargetGoal] {
        switch self {
        case .water: return [.overeating]
        case .alcohol: return [.delivery, .overeating]
        case .delivery: return [.overeating]
        case .overeating: return []
        }
    }

    // 목표 설정 화면 선택지 문자열 → 목표 (띄어쓰기 표기 차이 흡수: "외식 / 배달음식 줄이기")
    static func from(option: String) -> TargetGoal {
        let normalized = option.replacingOccurrences(of: " ", with: "")
        return allCases.first { $0.rawValue.replacingOccurrences(of: " ", with: "") == normalized } ?? .overeating
    }
}

// MARK: - 실행 맥락 (유형 테스트 결과가 이 값으로 매핑되어 1차 필터로 작동)

enum HabitContext: String, Codable {
    case any = "무관"
    case dining = "회식·외식형"
    case home = "집·개인공간형"
    case office = "사무실·좌식형"
    case diningDelivery = "회식·외식·배달형"

    // 회식·외식형 ↔ 회식·외식·배달형은 서로 호환되는 맥락으로 취급
    func matches(_ other: HabitContext) -> Bool {
        if self == other { return true }
        let diningGroup: Set<HabitContext> = [.dining, .diningDelivery]
        return diningGroup.contains(self) && diningGroup.contains(other)
    }
}

// MARK: - 습관 DB 레코드 (습관_추천_로직_DB.xlsx 습관DB 시트)

struct HabitRecord {
    let code: String            // D01~D10(식단), E01~E10(환경), X01~X10(운동)
    let category: HabitCategory
    let text: String
    let goal: TargetGoal
    let context: HabitContext
    let difficulty: Int         // 1~3
    let trigger: String         // 트리거 유형 (알림 시각 개인화에 사용)

    // 카드 이미지 번호 (D03 → 3, rutine_eat_3)
    var imageNumber: Int { Int(code.dropFirst()) ?? 1 }
    var imageName: String { "rutine_\(category.rawValue)_\(imageNumber)" }
}

enum HabitDatabase {
    static func habits(in category: HabitCategory) -> [HabitRecord] {
        all.filter { $0.category == category }
    }

    static func habit(code: String) -> HabitRecord? {
        all.first { $0.code == code }
    }

    static let all: [HabitRecord] = [
        // 식단 (D01~D10)
        HabitRecord(code: "D01", category: .eat, text: "식사 30분 전,\n물 500ml를 마신다", goal: .water, context: .any, difficulty: 2, trigger: "식사시간 연동"),
        HabitRecord(code: "D02", category: .eat, text: "첫 젓가락은 무조건\n초록색 채소를 집는다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사시작"),
        HabitRecord(code: "D03", category: .eat, text: "음식을 입에 넣으면\n숟가락을 식탁에 내려놓는다", goal: .overeating, context: .any, difficulty: 2, trigger: "식사중"),
        HabitRecord(code: "D04", category: .eat, text: "한 입당 최소 20번을 세어\n천천히 씹는다", goal: .overeating, context: .any, difficulty: 3, trigger: "식사중"),
        HabitRecord(code: "D05", category: .eat, text: "배가 고프면 물 한 잔을 마시고\n5분을 기다린다", goal: .water, context: .any, difficulty: 2, trigger: "허기감지"),
        HabitRecord(code: "D06", category: .eat, text: "식사 10분 전, 삶은 달걀이나\n견과류를 소량 먹는다", goal: .overeating, context: .dining, difficulty: 2, trigger: "식사시간 연동"),
        HabitRecord(code: "D07", category: .eat, text: "배가 부르기 시작하면\n즉시 민트향 껌을 씹는다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사중"),
        HabitRecord(code: "D08", category: .eat, text: "식사를 마치자마자\n화장실로 가서 양치질을 한다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사직후"),
        HabitRecord(code: "D09", category: .eat, text: "술 한 잔을 마실 때마다\n물 한 잔을 마신다", goal: .alcohol, context: .dining, difficulty: 2, trigger: "음주중"),
        HabitRecord(code: "D10", category: .eat, text: "드레싱은 뿌리지 않고\n종지에 담아 찍어 먹는다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사준비"),

        // 환경 (E01~E10)
        HabitRecord(code: "E01", category: .environment, text: "모든 식사는 평소보다\n치수가 작은 그릇에 담는다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사준비"),
        HabitRecord(code: "E02", category: .environment, text: "간식은 안이 보이지 않는\n불투명한 통에 담아 둔다", goal: .overeating, context: .home, difficulty: 1, trigger: "상시환경"),
        HabitRecord(code: "E03", category: .environment, text: "냉장고 문을 열면 바로 보이게\n씻은 채소를 배치한다", goal: .overeating, context: .home, difficulty: 2, trigger: "상시환경"),
        HabitRecord(code: "E04", category: .environment, text: "고칼로리 식품은 의자를 딛고\n올라가는 높은 곳에 둔다", goal: .overeating, context: .home, difficulty: 2, trigger: "상시환경"),
        HabitRecord(code: "E05", category: .environment, text: "배달 앱의 간편 결제\n카드 정보를 삭제한다", goal: .delivery, context: .diningDelivery, difficulty: 3, trigger: "상시환경"),
        HabitRecord(code: "E06", category: .environment, text: "식사할 때는 스마트폰을\n다른 방이나 가방에 넣는다", goal: .overeating, context: .any, difficulty: 2, trigger: "식사시작"),
        HabitRecord(code: "E07", category: .environment, text: "잠들기 전 내일 입을\n운동복을 머리맡에 둔다", goal: .overeating, context: .any, difficulty: 1, trigger: "취침전"),
        HabitRecord(code: "E08", category: .environment, text: "장을 볼 때 채소 코너에서만\n10분 이상 머문다", goal: .delivery, context: .any, difficulty: 2, trigger: "장보기"),
        HabitRecord(code: "E09", category: .environment, text: "저녁 10시 이후에는\n집안 조명을 어둡게 바꾼다", goal: .delivery, context: .home, difficulty: 2, trigger: "저녁시간"),
        HabitRecord(code: "E10", category: .environment, text: "무언가 먹을 때는 무조건\n식탁 의자에만 앉는다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사시작"),

        // 운동 (X01~X10)
        HabitRecord(code: "X01", category: .exercise, text: "3층 이하는 무조건 엘리베이터\n대신 계단을 이용한다", goal: .overeating, context: .office, difficulty: 2, trigger: "이동중"),
        HabitRecord(code: "X02", category: .exercise, text: "전화가 오면 무조건\n자리에서 일어나 걷는다", goal: .overeating, context: .office, difficulty: 1, trigger: "전화수신"),
        HabitRecord(code: "X03", category: .exercise, text: "양치질하는 3분 동안\n투명 의자 자세를 유지한다", goal: .overeating, context: .any, difficulty: 3, trigger: "양치시간"),
        HabitRecord(code: "X04", category: .exercise, text: "버스나 지하철 이용 시\n한 정거장 먼저 내린다", goal: .overeating, context: .any, difficulty: 2, trigger: "출퇴근"),
        HabitRecord(code: "X05", category: .exercise, text: "식사 후 즉시 자리에서 일어나\n집안을 서성인다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사직후"),
        HabitRecord(code: "X06", category: .exercise, text: "신호등 빨간불 대기 시\n발꿈치를 10번 들었다 내린다", goal: .overeating, context: .any, difficulty: 1, trigger: "이동중"),
        HabitRecord(code: "X07", category: .exercise, text: "눈이 뻑뻑하다 싶으면\n크게 뜨고 몸을 비튼다", goal: .overeating, context: .office, difficulty: 1, trigger: "업무중"),
        HabitRecord(code: "X08", category: .exercise, text: "이메일을 쓸 때는 노트북을\n높은 곳에 두고 선다", goal: .overeating, context: .office, difficulty: 2, trigger: "업무중"),
        HabitRecord(code: "X09", category: .exercise, text: "TV 광고가 나오면 무조건\n스쿼트를 5개씩 한다", goal: .overeating, context: .home, difficulty: 2, trigger: "TV시청중"),
        HabitRecord(code: "X10", category: .exercise, text: "의자에 앉아 있을 때 배에\n힘을 주는 '드로인'을 한다", goal: .overeating, context: .office, difficulty: 1, trigger: "상시(좌식)")
    ]
}

// MARK: - 유형(8종) → context / 우선 목표 / 난이도 시작값 (유형매핑 시트)

struct TypeMapping {
    let context: HabitContext
    let priorityGoal: TargetGoal
    let startDifficulty: Int

    static func mapping(for type: CatType) -> TypeMapping {
        switch type {
        case .type1: return TypeMapping(context: .any, priorityGoal: .overeating, startDifficulty: 2)
        case .type2: return TypeMapping(context: .dining, priorityGoal: .alcohol, startDifficulty: 1)
        case .type3: return TypeMapping(context: .any, priorityGoal: .overeating, startDifficulty: 1)
        case .type4: return TypeMapping(context: .office, priorityGoal: .delivery, startDifficulty: 2)
        case .type5: return TypeMapping(context: .home, priorityGoal: .overeating, startDifficulty: 1)
        case .type6: return TypeMapping(context: .diningDelivery, priorityGoal: .delivery, startDifficulty: 1)
        case .type7: return TypeMapping(context: .home, priorityGoal: .overeating, startDifficulty: 1)
        case .type8: return TypeMapping(context: .office, priorityGoal: .water, startDifficulty: 1)
        }
    }
}

// MARK: - 기간별 난이도 전개 (난이도커브 시트)

enum DifficultyCurve {
    // base: 기본 허용 난이도 상한 / max: 지난주 완료율이 높은 카테고리가 올라갈 수 있는 상한
    static func caps(week: Int, totalWeeks: Int) -> (base: Int, max: Int) {
        switch totalWeeks {
        case 2:
            return (1, 1)                       // 쉬운 성공 경험 반복, 난이도 상승 없음
        case 4:
            return week <= 2 ? (1, 1) : (2, 2)  // 기초 다지기 → 습관 스태킹
        default: // 6주
            if week <= 2 { return (1, 1) }
            if week <= 4 { return (2, 2) }
            return (2, 3)                       // 완료율 높은 카테고리만 3까지 상승
        }
    }
}
