import Foundation

public struct FeedbackCountWithRatioResponse: Decodable {
    let count: Int
    let feedbackType: FeedbackType
    let ratio: Double

    public enum FeedbackType: String, Decodable {
        case HandsAreFast = "HANDS_ARE_FAST"
        case FoodIsDelicious = "FOOD_IS_DELICIOUS"
        case HygieneIsClean = "HYGIENE_IS_CLEAN"
        case BossIsKind = "BOSS_IS_KIND"
        case CanPayByCard = "CAN_PAY_BY_CARD"
        case GoodValueForMoney = "GOOD_VALUE_FOR_MONEY"
        case GoodToEatInOneBite = "GOOD_TO_EAT_IN_ONE_BITE"
        case GotABonus = "GOT_A_BONUS"
    }
}
