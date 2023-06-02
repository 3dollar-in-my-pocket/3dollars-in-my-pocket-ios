import Foundation

struct FetchCategoryRequest: RequestType {
    var param: [String : Any]? {
        return nil
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var path: String {
        return "/api/v4/store/categories"
    }
}
