import Foundation

import Model

enum CategoryApi {
    case fetchCategories
}

extension CategoryApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchCategories:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchCategories:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .fetchCategories:
            return "/api/v4/store/categories"
        }
    }
}
