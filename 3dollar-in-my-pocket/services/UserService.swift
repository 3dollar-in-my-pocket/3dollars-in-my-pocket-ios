import Alamofire
import RxSwift

protocol UserServiceProtocol {
    func signin(request: SigninRequest) -> Observable<SigninResponse>
    
    func signinAnonymous() -> Observable<SigninResponse>
    
    func signup(request: SignupRequest) -> Observable<SigninResponse>
    
    func connectAccount(request: SigninRequest) -> Observable<String>
    
    func withdrawal() -> Observable<Void>
    
    func changeNickname(name: String) -> Observable<Void>
    
    func fetchUserInfo() -> Observable<UserInfoResponse>
    
    func fetchUserActivity() -> Observable<UserWithActivityResponse>
}

struct UserService: UserServiceProtocol {
    private let networkManager = NetworkManager()
    
    func signin(request: SigninRequest) -> Observable<SigninResponse> {
        let urlString = HTTPUtils.url + "/api/v2/login"
        let parameters = request.params
        let headers = HTTPUtils.jsonHeader()
        
        return self.networkManager.createPostObservable(
            class: SigninResponse.self,
            urlString: urlString,
            headers: headers,
            parameters: parameters
        )
    }
    
    func signinAnonymous() -> Observable<SigninResponse> {
        let urlString = HTTPUtils.url + "/api/v1/signup/anonymous"
        let headers = HTTPUtils.jsonHeader()
        
        return self.networkManager.createPostObservable(
            class: SigninResponse.self,
            urlString: urlString,
            headers: headers
        )
    }
    
    func signup(request: SignupRequest) -> Observable<SigninResponse> {
        return Observable.create { observer in
            let urlString = HTTPUtils.url + "/api/v2/signup"
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .post,
                parameters: request.parameters,
                encoding: JSONEncoding.default,
                headers: HTTPUtils.jsonHeader()
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(class: SigninResponse.self, response: response)
                } else {
                    if response.response?.statusCode == 409 {
                        observer.onError(SignupError.alreadyExistedNickname)
                    } else if response.response?.statusCode == 400 {
                        observer.onError(SignupError.badRequest)
                    } else {
                        observer.processHTTPError(response: response)
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func connectAccount(request: SigninRequest) -> Observable<String> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/connect/account"
            let headers = HTTPUtils.defaultHeader()
            let params = request.params
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseData { response in
                if response.isSuccess() {
                    observer.processValue(class: String.self, response: response)
                } else {
                    if response.response?.statusCode == 409 {
                        observer.onError(SignupError.alreadyExistedNickname)
                    } else {
                        observer.processAPIError(response: response)
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func withdrawal() -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/signout"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .delete,
                headers: headers
            )
            .responseString(completionHandler: { (response) in
                if let statusCode = response.response?.statusCode {
                    if "\(statusCode)".first! == "2" {
                        observer.onNext(())
                        observer.onCompleted()
                    }
                } else {
                    observer.processHTTPError(response: response)
                }
            })
            
            return Disposables.create()
        }
    }
    
    func changeNickname(name: String) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/user/me"
            let headers = HTTPUtils.defaultHeader()
            let parameters: [String: Any] = ["name": name]
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .put,
                parameters: parameters,
                encoding: JSONEncoding.default,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.onNext(())
                    observer.onCompleted()
                } else {
                    if response.response?.statusCode == 409 {
                        observer.onError(ChangeNicknameError.alreadyExistedNickname)
                    } else if response.response?.statusCode == 400 {
                        observer.onError(ChangeNicknameError.badRequest)
                    } else {
                        observer.processHTTPError(response: response)
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    func fetchUserInfo() -> Observable<UserInfoResponse> {
        return Observable.create { observer -> Disposable in
            let urlString = HTTPUtils.url + "/api/v2/user/me"
            let headders = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headders
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: UserInfoResponse.self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchUserActivity() -> Observable<UserWithActivityResponse> {
        return .create { observer in
            let urlString = HTTPUtils.url + "/api/v1/user/activity"
            let headers = HTTPUtils.defaultHeader()
            
            HTTPUtils.defaultSession.request(
                urlString,
                method: .get,
                headers: headers
            ).responseJSON { response in
                if response.isSuccess() {
                    observer.processValue(class: UserWithActivityResponse.self, response: response)
                } else {
                    observer.processHTTPError(response: response)
                }
            }
            
            return Disposables.create()
        }
    }
}
