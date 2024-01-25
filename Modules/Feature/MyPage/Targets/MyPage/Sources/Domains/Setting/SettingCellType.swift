import Foundation

import Model

enum SettingCellType {
    case account(name: String, socialType: SocialType)
    case activityNotification(isOn: Bool)
    case marketingNotification(isOn: Bool)
    case qna
    case agreement
    case teamInfo
    case signout
    
    var title: String? {
        switch self {
        case .account:
            return nil
        case .activityNotification:
            return Strings.Setting.activityNotifictaion
        case .marketingNotification:
            return Strings.Setting.marketingNotification
        case .qna:
            return Strings.Setting.qna
        case .agreement:
            return Strings.Setting.agreement
        case .teamInfo:
            return Strings.Setting.teamInfo
        case .signout:
            return nil
        }
    }
    
    var isHiddenSwitch: Bool {
        switch self {
        case .account:
            return true
        case .activityNotification:
            return false
        case .marketingNotification:
            return false
        case .qna:
            return true
        case .agreement:
            return true
        case .teamInfo:
            return true
        case .signout:
            return true
        }
    }
    
    var isHiddenArrow: Bool {
        switch self {
        case .account:
            return true
        case .activityNotification:
            return true
        case .marketingNotification:
            return true
        case .qna:
            return false
        case .agreement:
            return false
        case .teamInfo:
            return false
        case .signout:
            return true
        }
    }
}
