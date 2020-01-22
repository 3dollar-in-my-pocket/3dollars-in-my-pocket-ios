import Alamofire
import ObjectMapper

struct CategoryService: APIServiceType {
    static func getStroeByDistance(category: StoreCategory, latitude: Double, longitude: Double, completion: @escaping (DataResponse<CategoryByDistance>) -> Void) {
        let urlString = self.url("api/v1/category/distance")
        let headers = self.defaultHeader()
        let parameters: [String: Any] = ["category": category.getValue(), "latitude": latitude, "longitude": longitude]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            let response: DataResponse<CategoryByDistance> = response.flatMapResult { (json) in
                if let category = Mapper<CategoryByDistance>().map(JSONObject: json) {
                    return .success(category)
                } else {
                    return .failure(MappingError.init(from: json, to: CategoryByDistance.self))
                }
            }
            
            completion(response)
        }
    }
    
    static func getStoreByReview(category: StoreCategory, latitude: Double, longitude: Double, completion: @escaping (DataResponse<CategoryByReview>) -> Void) {
        let urlString = self.url("api/v1/category/review")
        let headers = self.defaultHeader()
        let parameters: [String: Any] = ["category": category.getValue(), "latitude": latitude, "longitude": longitude]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            let response: DataResponse<CategoryByReview> = response.flatMapResult { (json) in
                if let category = Mapper<CategoryByReview>().map(JSONObject: json) {
                    return .success(category)
                } else {
                    return .failure(MappingError.init(from: json, to: CategoryByReview.self))
                }
            }
            
            completion(response)
        }
    }
}
