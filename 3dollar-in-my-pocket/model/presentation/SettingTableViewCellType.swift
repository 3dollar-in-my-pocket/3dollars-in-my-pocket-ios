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
            return UIImage(named: "ic_push")
            
        case .question:
            return UIImage(named: "ic_setting_notice")
            
        case .policy:
            return UIImage(named: "ic_setting_message")
            
        case .privacy:
            return UIImage(named: "ic_setting_message")
            
        case .account:
            return nil
            
        case .signout:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .push:
            return "setting_menu_push".localized
            
        case .question:
            return "setting_menu_question".localized
            
        case .policy:
            return "setting_menu_policy".localized
            
        case .privacy:
            return "setting_menu_privacy".localized
            
        case .account:
            return nil
            
        case .signout:
            return nil
        }
    }
}
