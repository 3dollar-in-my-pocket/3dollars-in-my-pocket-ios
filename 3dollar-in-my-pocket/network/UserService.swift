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
    
    static func changeNickname(nickname: String, completion: @escaping (DataResponse<String>) -> Void) {
        let urlString = self.url("api/v1/user/nickname")
        let parameters: [String: Any] = ["nickname": nickname, "userId": UserDefaultsUtil.getUserId()!]
        let headers = self.defaultHeader()
        
        Alamofire.request(urlString, method: .put, parameters: parameters, headers: headers).responseString(completionHandler: { (response) in
            completion(response)
        })
    }
    
    // 마이페이지 > 닉네임 변경 API와 따로 구현
    // 초기 닉네임 설정하는 화면에서는 토큰과 id가 UserDefault에 저장되어있으면 안되기 떄문에 입력값으로 받음
    static func setNickname(nickname: String, id: Int, token: String, completion: @escaping (DataResponse<String>) -> Void) {
        let urlString = self.url("api/v1/user/nickname")
        let parameters: [String: Any] = ["nickName": nickname, "userId": id]
        let headers = ["Authorization": token]
        
        Alamofire.request(urlString, method: .put, parameters: parameters, headers: headers).responseString(completionHandler: { (response) in
            completion(response)
        })
    }
    
    static func getUserInfo(completion: @escaping ((DataResponse<User>) -> Void)) {
        let urlString = self.url("api/v1/user/info")
        let headders = self.defaultHeader()
        var parameters: [String: Any] = [ : ]
        
        if let userId = UserDefaultsUtil.getUserId() {
            parameters["userId"] = userId
        }
        
        Alamofire.request(urlString, method: .get, parameters: parameters, headers: headders).responseJSON { (response) in
            let response: DataResponse<User> = response.flatMapResult { (json) in
                if let user = Mapper<User>().map(JSONObject: json) {
                    return .success(user)
                } else {
                    return .failure(MappingError.init(from: json, to: User.self))
                }
            }
            
            completion(response)
        }
        
        
    }
}
