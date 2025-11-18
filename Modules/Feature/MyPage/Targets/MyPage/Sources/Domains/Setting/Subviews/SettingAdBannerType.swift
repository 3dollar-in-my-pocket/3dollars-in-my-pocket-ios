import UIKit

enum SettingAdBannerType {
    /// 자체 광고
    case normal
    
    /// 사장님 앱 광고
    case boss
    
    var title: String {
        switch self {
        case .normal:
            return Strings.Setting.Ad.Normal.title
        case .boss:
            return Strings.Setting.Ad.Boss.title
        }
    }
    
    var titleColor: UIColor {
        switch self {
        case .normal:
            return Colors.mainPink.color
        case .boss:
            return Colors.mainGreen.color
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return Strings.Setting.Ad.Normal.description
        case .boss:
            return Strings.Setting.Ad.Boss.description
        }
    }
    
    var bannerImage: UIImage {
        switch self {
        case .normal:
            return Images.imageBannerNormal.image
        case .boss:
            return Images.imageBannerBoss.image
        }
    }
    
    var url: String {
        switch self {
        case .normal:
            return "https://massive-iguana-121.notion.site/3-ff344e306d0c4417973daee8792cfe4d"
        case .boss:
            return "https://massive-iguana-121.notion.site/3-28c7ad52990e809caba2fb2040677a2a?pvs=74"
        }
    }
}
