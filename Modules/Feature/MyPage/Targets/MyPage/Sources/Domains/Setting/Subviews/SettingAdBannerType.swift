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
            return "https://apps.apple.com/kr/app/%EA%B0%80%EC%8A%B4%EC%86%8D-3%EC%B2%9C%EC%9B%90-%EC%82%AC%EC%9E%A5%EB%8B%98/id1639708958"
        }
    }
}
