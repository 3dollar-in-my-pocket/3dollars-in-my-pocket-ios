import Alamofire
import ObjectMapper

struct ReviewService: APIServiceType {
    static func saveReview(review: Review, storeId: Int, completion: @escaping ((DataResponse<String>) -> Void)) {
        let urlString = self.url("api/v1/review/save")
        let headers = self.jsonWithTokenHeader()
        var parameter = review.toJSON()
        
        parameter["storeId"] = storeId
        if let userId = UserDefaultsUtil.getUserId() {
            parameter["userId"] = userId
        }
        
        Alamofire.request(urlString, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
            completion(response)
        }
    }
}
