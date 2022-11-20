import UIKit

enum SettingTableViewCellType {
    case push(isOn: Bool)
    case question
    case policy
    case privacy
    case account(User)
    case signout
}

extension SettingTableViewCellType {
    static func toCellType(user: User) -> [SettingTableViewCellType] {
        return [
            .push(isOn: user.pushInfo.isPushEnable),
            .question,
            .policy,
            .privacy,
            .account(user),
            .signout
        ]
    }
    
    var icon: UIImage? {
        switch self {
        case .push:
            return R.image.ic_push()
            
        case .question:
            return R.image.ic_setting_notice()
            
        case .policy:
            return R.image.ic_setting_message()
            
        case .privacy:
            return R.image.ic_setting_message()
            
        case .account:
            return nil
            
        case .signout:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .push:
            return R.string.localization.setting_menu_push()
            
        case .question:
            return R.string.localization.setting_menu_question()
            
        case .policy:
            return R.string.localization.setting_menu_policy()
            
        case .privacy:
            return R.string.localization.setting_menu_privacy()
            
        case .account:
            return nil
            
        case .signout:
            return nil
        }
    }
}
