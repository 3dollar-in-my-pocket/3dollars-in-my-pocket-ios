import Alamofire
import ObjectMapper

struct UserService: APIServiceType {
    
    static func signIn(user: User, completion: @escaping (DataResponse<SignIn>) -> Void) {
        let urlString = self.url("api/v1/user/login")
        let parameters = user.toDict()
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.jsonHeader()).responseJSON { (response) in
            
            let response: DataResponse<SignIn> = response.flatMapResult { json in
                if let signIn = Mapper<SignIn>().map(JSONObject: response.result.value) {
                    return .success(signIn)
                } else {
                    return .failure(MappingError.init(from: response, to: SignIn.self))
                }
            }
            completion(response)
        }
    }
}
