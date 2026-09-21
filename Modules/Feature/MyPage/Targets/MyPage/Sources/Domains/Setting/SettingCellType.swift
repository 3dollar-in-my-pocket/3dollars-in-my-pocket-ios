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
        }
    }
}
