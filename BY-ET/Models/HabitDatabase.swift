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

// MARK: - 습관 DB 레코드 (습관DB_최종본_69개.xlsx 습관DB 시트)

struct HabitRecord {
    let code: String            // D01~D23(식단), E01~E23(환경), X01~X23(운동)
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
        // 식단 (D01~D23)
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
        HabitRecord(code: "D11", category: .eat, text: "식전 레몬 물\n한 모금 마시기", goal: .water, context: .any, difficulty: 1, trigger: "식사시간 연동"),
        HabitRecord(code: "D12", category: .eat, text: "밥 먹을 때 국물이나 음료 대신\n물만 마신다", goal: .water, context: .any, difficulty: 3, trigger: "식사중"),
        HabitRecord(code: "D13", category: .eat, text: "술자리 첫 잔은\n논알코올 음료로 시작한다", goal: .alcohol, context: .dining, difficulty: 1, trigger: "음주시작"),
        HabitRecord(code: "D14", category: .eat, text: "회식 자리에서 탄산수를\n최소 2잔 마신다", goal: .alcohol, context: .dining, difficulty: 3, trigger: "음주중"),
        HabitRecord(code: "D15", category: .eat, text: "배달 앱을 켜기 전, 냉장고 속\n재료 사진을 먼저 찍어본다", goal: .delivery, context: .diningDelivery, difficulty: 1, trigger: "배달충동시"),
        HabitRecord(code: "D16", category: .eat, text: "외식 시 나온 채소 반찬은\n남기지 않고 다 먹는다", goal: .delivery, context: .dining, difficulty: 2, trigger: "외식중"),
        HabitRecord(code: "D17", category: .eat, text: "이번 주 배달음식 허용 횟수를\n미리 정하고 스티커로 관리한다", goal: .delivery, context: .diningDelivery, difficulty: 3, trigger: "주간계획"),
        HabitRecord(code: "D18", category: .eat, text: "술을 마시든 혼술이든, 마시기 전\n물 한 잔을 먼저 마신다", goal: .alcohol, context: .any, difficulty: 1, trigger: "음주시작"),
        HabitRecord(code: "D19", category: .eat, text: "술 마실 때 안주는 채소류를\n가장 먼저 집어 먹는다", goal: .alcohol, context: .any, difficulty: 2, trigger: "음주중"),
        HabitRecord(code: "D20", category: .eat, text: "술 마신 날은 스스로 정한\n잔 수(예: 2잔)를 넘기지 않는다", goal: .alcohol, context: .any, difficulty: 3, trigger: "음주중"),
        HabitRecord(code: "D21", category: .eat, text: "배달 시키기 전, 15분 내로 만들 수\n있는 재료가 있는지 확인한다", goal: .delivery, context: .any, difficulty: 1, trigger: "배달충동시"),
        HabitRecord(code: "D22", category: .eat, text: "외식·배달 메뉴를 고를 때\n튀김류 대신 구이·찜류를 선택한다", goal: .delivery, context: .any, difficulty: 2, trigger: "주문시"),
        HabitRecord(code: "D23", category: .eat, text: "이번 주 배달/외식 횟수를 미리\n정해두고 그 이상은 먹지 않는다", goal: .delivery, context: .any, difficulty: 3, trigger: "주간계획"),

        // 환경 (E01~E23)
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
        HabitRecord(code: "E11", category: .environment, text: "외출 시 500ml 텀블러를\n항상 휴대한다", goal: .water, context: .any, difficulty: 1, trigger: "외출전"),
        HabitRecord(code: "E12", category: .environment, text: "눈금이 그려진\n전용 물병을 사용한다", goal: .water, context: .any, difficulty: 2, trigger: "상시환경"),
        HabitRecord(code: "E13", category: .environment, text: "책상, 침대맡, 거실에\n물병을 각각 배치해둔다", goal: .water, context: .home, difficulty: 3, trigger: "상시환경"),
        HabitRecord(code: "E14", category: .environment, text: "체중계를 거실 통로\n중앙에 배치한다", goal: .overeating, context: .home, difficulty: 3, trigger: "상시환경"),
        HabitRecord(code: "E15", category: .environment, text: "술 보관 칸을 냉장고 맨 아래,\n눈에 안 띄는 곳으로 옮긴다", goal: .alcohol, context: .home, difficulty: 1, trigger: "상시환경"),
        HabitRecord(code: "E16", category: .environment, text: "집에 있는 술은 수납장 안쪽\n깊숙이 밀봉해서 보관한다", goal: .alcohol, context: .home, difficulty: 2, trigger: "상시환경"),
        HabitRecord(code: "E17", category: .environment, text: "술을 살 때는 소량 사이즈만\n구매하는 규칙을 정한다", goal: .alcohol, context: .any, difficulty: 3, trigger: "장보기"),
        HabitRecord(code: "E18", category: .environment, text: "장보기 목록을 적고\n그 목록만 구매한다", goal: .delivery, context: .any, difficulty: 1, trigger: "장보기"),
        HabitRecord(code: "E19", category: .environment, text: "책상, 침대맡 등 최소 두 곳에\n물병을 배치해둔다", goal: .water, context: .any, difficulty: 3, trigger: "상시환경"),
        HabitRecord(code: "E20", category: .environment, text: "체중을 기록하는 앱이나 수첩을\n매일 보이는 곳에 둔다", goal: .overeating, context: .any, difficulty: 3, trigger: "상시환경"),
        HabitRecord(code: "E21", category: .environment, text: "술을 사기 전, 결제 직전에 '오늘\n꼭 필요한가' 한 번 더 확인한다", goal: .alcohol, context: .any, difficulty: 1, trigger: "장보기"),
        HabitRecord(code: "E22", category: .environment, text: "술 마시고 남은 병은 그날 바로\n정리해 눈에 안 띄게 치운다", goal: .alcohol, context: .any, difficulty: 2, trigger: "상시환경"),
        HabitRecord(code: "E23", category: .environment, text: "배달 앱 알림을 꺼서\n먼저 눈에 띄지 않게 한다", goal: .delivery, context: .any, difficulty: 3, trigger: "상시환경"),

        // 운동 (X01~X23)
        HabitRecord(code: "X01", category: .exercise, text: "3층 이하는 무조건 엘리베이터\n대신 계단을 이용한다", goal: .overeating, context: .office, difficulty: 2, trigger: "이동중"),
        HabitRecord(code: "X02", category: .exercise, text: "전화가 오면 무조건\n자리에서 일어나 걷는다", goal: .overeating, context: .office, difficulty: 1, trigger: "전화수신"),
        HabitRecord(code: "X03", category: .exercise, text: "양치질하는 3분 동안\n투명 의자 자세를 유지한다", goal: .overeating, context: .any, difficulty: 3, trigger: "양치시간"),
        HabitRecord(code: "X04", category: .exercise, text: "버스나 지하철 이용 시\n한 정거장 먼저 내린다", goal: .overeating, context: .any, difficulty: 2, trigger: "출퇴근"),
        HabitRecord(code: "X05", category: .exercise, text: "식사 후 즉시 자리에서 일어나\n집안을 서성인다", goal: .overeating, context: .any, difficulty: 1, trigger: "식사직후"),
        HabitRecord(code: "X06", category: .exercise, text: "신호등 빨간불 대기 시\n발꿈치를 10번 들었다 내린다", goal: .overeating, context: .any, difficulty: 1, trigger: "이동중"),
        HabitRecord(code: "X07", category: .exercise, text: "눈이 뻑뻑하다 싶으면\n크게 뜨고 몸을 비튼다", goal: .overeating, context: .office, difficulty: 1, trigger: "업무중"),
        HabitRecord(code: "X08", category: .exercise, text: "이메일을 쓸 때는 노트북을\n높은 곳에 두고 선다", goal: .overeating, context: .office, difficulty: 2, trigger: "업무중"),
        HabitRecord(code: "X09", category: .exercise, text: "TV 광고가 나오면 무조건\n스쿼트를 5개씩 한다", goal: .overeating, context: .home, difficulty: 2, trigger: "TV시청중"),
        HabitRecord(code: "X10", category: .exercise, text: "의자에 앉아 있을 때 배에\n힘을 주는 '드로인'을 한다", goal: .overeating, context: .office, difficulty: 1, trigger: "상시(좌식)"),
        HabitRecord(code: "X11", category: .exercise, text: "작은 물컵을 써서\n자주 물을 뜨러 간다", goal: .water, context: .any, difficulty: 1, trigger: "상시(좌식)"),
        HabitRecord(code: "X12", category: .exercise, text: "1시간마다 정수기까지\n왕복으로 걸어가 물을 뜬다", goal: .water, context: .office, difficulty: 2, trigger: "업무중"),
        HabitRecord(code: "X13", category: .exercise, text: "물을 마시러 갈 때 계단을\n오르내리는 경로로 다녀온다", goal: .water, context: .any, difficulty: 3, trigger: "상시"),
        HabitRecord(code: "X14", category: .exercise, text: "술자리 후 귀가하면\n바로 스트레칭을 5분 한다", goal: .alcohol, context: .dining, difficulty: 1, trigger: "귀가직후"),
        HabitRecord(code: "X15", category: .exercise, text: "회식 다음날은 평소보다\n10분 일찍 일어나 걷는다", goal: .alcohol, context: .dining, difficulty: 2, trigger: "익일아침"),
        HabitRecord(code: "X16", category: .exercise, text: "술을 마신 다음날은\n30분 이상 걷기를 실천한다", goal: .alcohol, context: .dining, difficulty: 3, trigger: "익일"),
        HabitRecord(code: "X17", category: .exercise, text: "마트에서 카트 대신\n장바구니를 든다", goal: .delivery, context: .any, difficulty: 1, trigger: "장보기"),
        HabitRecord(code: "X18", category: .exercise, text: "1km 이내 거리는\n무조건 도보로 이동한다", goal: .delivery, context: .any, difficulty: 2, trigger: "이동중"),
        HabitRecord(code: "X19", category: .exercise, text: "장보기는 대형마트 대신\n재래시장까지 걸어가서 한다", goal: .delivery, context: .any, difficulty: 3, trigger: "장보기"),
        HabitRecord(code: "X20", category: .exercise, text: "1시간마다 알람을 맞추고,\n울리면 물 마시러 일어난다", goal: .water, context: .any, difficulty: 2, trigger: "업무중"),
        HabitRecord(code: "X21", category: .exercise, text: "술자리 전, 미리 5분\n스트레칭으로 몸을 풀어둔다", goal: .alcohol, context: .any, difficulty: 1, trigger: "음주전"),
        HabitRecord(code: "X22", category: .exercise, text: "술 마신 날은 잠들기 전 가벼운\n스트레칭을 10분 한다", goal: .alcohol, context: .any, difficulty: 2, trigger: "취침전"),
        HabitRecord(code: "X23", category: .exercise, text: "술을 마신 다음날 아침,\n평소보다 15분 더 걷는다", goal: .alcohol, context: .any, difficulty: 3, trigger: "익일아침")
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
