import Alamofire
import ObjectMapper

struct CategoryService: APIServiceType {
    static func getStroeByDistance(category: StoreCategory, latitude: Double, longitude: Double, completion: @escaping (DataResponse<Category>) -> Void) {
        let urlString = self.url("api/v1/category/distance")
        let headers = self.defaultHeader()
        let parameters: [String: Any] = ["category": category.getValue(), "latitude": latitude, "longitude": longitude]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            let response: DataResponse<Category> = response.flatMapResult { (json) in
                if let category = Mapper<Category>().map(JSONObject: json) {
                    return .success(category)
                } else {
                    return .failure(MappingError.init(from: json, to: Category.self))
                }
            }
            
            completion(response)
        }
    }
    
    static func getStoreByStar(category: StoreCategory, latitude: Double, longitude: Double, completion: @escaping (DataResponse<Category>) -> Void) {
        let urlString = self.url("api/v1/category/review")
        let headers = self.defaultHeader()
        let parameters: [String: Any] = ["category": category.getValue(), "latitude": latitude, "longitude": longitude]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            let response: DataResponse<Category> = response.flatMapResult { (json) in
                if let category = Mapper<Category>().map(JSONObject: json) {
                    return .success(category)
                } else {
                    return .failure(MappingError.init(from: json, to: Category.self))
                }
            }
            
            completion(response)
        }
    }
}
