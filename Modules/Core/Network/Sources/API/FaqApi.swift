import Foundation

import Model

enum FaqApi {
    case fetchFaq(category: String?)
    case fetchFaqCategory
}

extension FaqApi: RequestType {
    var param: Encodable? {
        switch self {
        case .fetchFaq(let category):
            guard let category else { return nil }
            
            return ["category": category]
        case .fetchFaqCategory:
            return nil
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .fetchFaq:
            return .get
        case .fetchFaqCategory:
            return .get
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .fetchFaq:
            return .json
        case .fetchFaqCategory:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .fetchFaq:
            return "/api/v2/faqs"
        case .fetchFaqCategory:
            return "/api/v2/faq/categories"
        }
    }
}
