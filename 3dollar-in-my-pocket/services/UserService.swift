import Alamofire
import RxSwift

protocol UserServiceProtocol {
  
  func signin(request: SigninRequest) -> Observable<SigninResponse>
  
  func signup(request: SignupRequest) -> Observable<SigninResponse>
  
  func withdrawal() -> Observable<Void>
  
  func changeNickname(name: String) -> Observable<User>
  
  func fetchUserInfo() -> Observable<UserInfoResponse>
}

struct UserService: UserServiceProtocol {
  
  func signin(request: SigninRequest) -> Observable<SigninResponse> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v2/login"
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .post,
        parameters: request.parameters,
        encoding: JSONEncoding.default,
        headers: HTTPUtils.jsonHeader()
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: SigninResponse.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
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
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: SigninResponse.self, response: response)
          observer.onCompleted()
        } else {
          observer.processHTTPError(response: response)
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
        }
        observer.processHTTPError(response: response)
      })
      
      return Disposables.create()
    }
  }
  
  func changeNickname(name: String) -> Observable<User> {
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
          observer.processValue(class: User.self, response: response)
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
}
