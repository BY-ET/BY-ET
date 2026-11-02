import Foundation

enum NicknameGenerator {
    private static let adjectives = [
        "꾸준한", "부지런한", "성실한", "씩씩한", "기운찬", "용감한", "신나는", "반짝이는",
        "명랑한", "포근한", "느긋한", "말랑한", "우아한", "사뿐한", "빛나는", "꿋꿋한",
        "단단한", "든든한", "힘찬", "튼튼한", "당당한", "자유로운", "산뜻한", "상큼한",
        "다정한", "촉촉한", "싱그러운", "보송한", "똘똘한", "행복한"
    ]

    private static let nouns = [
        "집사", "냥이", "츄르", "젤리", "꼬리", "수염", "발바닥", "캣닢", "꾹꾹이",
        "골골이", "솜방망이", "냥펀치", "우다다", "털뭉치", "캣타워", "숨숨집", "방울",
        "쥐돌이", "스크래처", "털실", "아깽이", "삼색이", "턱시도", "노랑이", "하품",
        "그루밍", "기지개", "캔따개", "냥냥이", "낮잠"
    ]

    static func random() -> String {
        let adj = adjectives.randomElement() ?? "행복한"
        let noun = nouns.randomElement() ?? "냥이"
        return "\(adj) \(noun)"
    }
}
