import Alamofire
import ObjectMapper

struct ReviewService: APIServiceType {
    static func saveReview(review: Review, storeId: Int, completion: @escaping ((DataResponse<String>) -> Void)) {
        let urlString = self.url("api/v1/review/save?storeId=\(storeId)&userId=\(UserDefaultsUtil.getUserId()!)")
        let headers = self.jsonWithTokenHeader()
        let parameter = review.toJSON()
        
        Alamofire.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
            completion(response)
        }
    }
    
    static func getMyReview(page: Int, completion: @escaping (DataResponse<Page<Review>>) -> Void) {
        let urlString = self.url("api/v1/review/user")
        let headers = self.defaultHeader()
        let parameters: [String: Any] = ["page": page, "userId": UserDefaultsUtil.getUserId()!]
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            let response: DataResponse<Page<Review>> = response.flatMapResult { (json) in
                if let reviewPage = Mapper<Page<Review>>().map(JSONObject: json) {
                    return .success(reviewPage)
                } else {
                    return .failure(MappingError.init(from: json, to: Page<Review>.self))
                }
            }
            
            completion(response)
        }
    }
}
