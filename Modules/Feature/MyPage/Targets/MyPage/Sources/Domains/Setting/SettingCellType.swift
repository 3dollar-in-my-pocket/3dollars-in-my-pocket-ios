import Foundation

import Model

enum SettingCellType {
    case account(name: String, socialType: SocialType)
    case activityNotification(isOn: Bool)
    case marketingNotification(isOn: Bool)
    case accountInfo
    case qna
    case agreement
    case teamInfo
    case signout
    case advertisement(SettingAdBannerType)
    /// 디버깅 전용. 프로덕션 빌드에서는 목록에 추가되지 않는다.
    case debugStoreId(isOn: Bool)
    
    var title: String? {
        switch self {
        case .account:
            return nil
        case .activityNotification:
            return Strings.Setting.ActivityNotification.title
        case .marketingNotification:
            return Strings.Setting.MarketingNotification.title
        case .accountInfo:
            return Strings.Setting.accountInfo
        case .qna:
            return Strings.Setting.qna
        case .agreement:
            return Strings.Setting.agreement
        case .teamInfo:
            return Strings.Setting.teamInfo
        case .advertisement:
            return nil
        case .signout:
            return nil
        case .debugStoreId:
            // 디버깅 전용 메뉴라 현지화하지 않는다.
            return "[디버그] 가게 ID 표시"
        }
    }
    
    var description: String? {
        switch self {
        case .account:
            return nil
        case .activityNotification:
            return Strings.Setting.ActivityNotification.description
        case .marketingNotification:
            return Strings.Setting.MarketingNotification.description
        case .accountInfo:
            return nil
        case .qna:
            return nil
        case .agreement:
            return nil
        case .teamInfo:
            return nil
        case .advertisement:
            return nil
        case .signout:
            return nil
        case .debugStoreId:
            return "가게 상세에서 가게 ID 플로팅 뷰를 띄웁니다"
        }
    }
}
