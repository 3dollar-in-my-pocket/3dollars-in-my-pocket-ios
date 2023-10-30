public enum FeedbackType: String, Decodable, Equatable {
    case HandsAreFast = "HANDS_ARE_FAST"
    case FoodIsDelicious = "FOOD_IS_DELICIOUS"
    case HygieneIsClean = "HYGIENE_IS_CLEAN"
    case BossIsKind = "BOSS_IS_KIND"
    case CanPayByCard = "CAN_PAY_BY_CARD"
    case GoodValueForMoney = "GOOD_VALUE_FOR_MONEY"
    case GoodToEatInOneBite = "GOOD_TO_EAT_IN_ONE_BITE"
    case GotABonus = "GOT_A_BONUS"

    public var emoji: String {
        switch self {
        case .HandsAreFast:
            "👐"
        case .FoodIsDelicious:
            "🍕"
        case .HygieneIsClean:
            "✨"
        case .BossIsKind:
            "🙏"
        case .CanPayByCard:
            "💳"
        case .GoodValueForMoney:
            "💰"
        case .GoodToEatInOneBite:
            "👌"
        case .GotABonus:
            "👍"
        }
    }

    public var description: String {
        switch self {
        case .HandsAreFast:
            "손이 빠르세요"
        case .FoodIsDelicious:
            "음식이 맛있어요"
        case .HygieneIsClean:
            "위생이 청결해요"
        case .BossIsKind:
            "사장님이 친절해요"
        case .CanPayByCard:
            "카드 결제 가능해요"
        case .GoodValueForMoney:
            "가격이 저렴해요"
        case .GoodToEatInOneBite:
            "한입에 먹기 좋아요"
        case .GotABonus:
            "덤도 주셨어요"
        }
    }
}
