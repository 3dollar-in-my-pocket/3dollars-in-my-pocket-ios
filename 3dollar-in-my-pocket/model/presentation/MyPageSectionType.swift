import UIKit

enum MyPageSectionType {
    case visitHistory
    case bookmark
    case unknown
    
    init(sectionIndex: Int) {
        switch sectionIndex {
        case 1:
            self = .visitHistory
            
        case 2:
            self = .bookmark
            
        default:
            self = .unknown
        }
    }
}

extension MyPageSectionType {
    var icon: UIImage? {
        switch self {
        case .visitHistory:
            return UIImage(named: "ic_bedge")?.withRenderingMode(.alwaysTemplate)
            
        case .bookmark:
            return UIImage(named: "ic_bookmark_on")?.withRenderingMode(.alwaysTemplate)
            
        case .unknown:
            return nil
        }
    }
    
    var iconLabel: String {
        switch self {
        case .visitHistory:
            return "my_page_visit".localized
            
        case .bookmark:
            return "store_detail_bookmark".localized
            
        case .unknown:
            return ""
        }
    }
    
    var title: String {
        switch self {
        case .visitHistory:
            return "my_page_visit_description".localized
            
        case .bookmark:
            return "my_page_bookmark_description".localized
            
        case .unknown:
            return ""
        }
    }
}
