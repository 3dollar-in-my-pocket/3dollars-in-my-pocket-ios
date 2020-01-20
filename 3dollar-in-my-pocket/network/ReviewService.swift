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
}
