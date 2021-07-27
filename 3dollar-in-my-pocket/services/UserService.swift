import Alamofire
import RxSwift

protocol UserServiceProtocol {
  
  func validateToken(token: String) -> Observable<Void>
  
  func signIn(user: User) -> Observable<SignIn>
  
  func setNickname(
    nickname: String,
    id: Int,
    token: String
  ) -> Observable<Void>
  
  func getUserInfo(userId: Int) -> Observable<User>
  
  func withdrawal(userId: Int) -> Observable<Void>
  
  func changeNickname(nickname: String) -> Observable<String>
  
  func getUserInfo() -> Observable<User>
}

struct UserService: UserServiceProtocol {
  
  func validateToken(token: String) -> Observable<Void> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/me"
      let headers = HTTPUtils.defaultHeader()
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        headers: headers
      ).responseString { response in
        if response.isSuccess() {
          observer.onNext(())
          observer.onCompleted()
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func signIn(user: User) -> Observable<SignIn> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/login"
      let parameters = user.toDict()
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .post,
        parameters: parameters,
        encoding: JSONEncoding.default,
        headers: HTTPUtils.jsonHeader()
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: SignIn.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      
      return Disposables.create()
    }
  }
  
  func setNickname(
    nickname: String,
    id: Int,
    token: String
  ) -> Observable<Void> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/nickname"
      let parameters: [String: Any] = ["nickName": nickname, "userId": id]
      var headers = ["Authorization": token] as HTTPHeaders
      
      headers.add(HTTPUtils.defaultUserAgent)
      HTTPUtils.defaultSession.request(
        urlString,
        method: .put,
        parameters: parameters,
        headers: headers
      ).responseString(completionHandler: { (response) in
        if response.isSuccess() {
          observer.onNext(())
          observer.onCompleted()
        } else {
          observer.processHTTPError(response: response)
        }
      })
      
      return Disposables.create()
    }
  }
  
  func getUserInfo(userId: Int) -> Observable<User> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/info"
      let headders = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["userId" : String(userId)]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headders
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: User.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
  
  func withdrawal(userId: Int) -> Observable<Void> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/signout"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["userId": userId]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .post,
        parameters: parameters,
        encoding: URLEncoding.default,
        headers: headers
      ).responseString(completionHandler: { (response) in
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
  
  func changeNickname(nickname: String) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/nickname"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = [
        "nickName": nickname,
        "userId": UserDefaultsUtil.getUserId() ?? ""
      ]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .put,
        parameters: parameters,
        headers: headers
      ).responseString(completionHandler: { response in
        if response.isSuccess() {
          observer.onNext("success")
          observer.onCompleted()
        } else {
          observer.processHTTPError(response: response)
        }
      })
      
      return Disposables.create()
    }
  }
  
  func getUserInfo() -> Observable<User> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/info"
      let headders = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["userId" : UserDefaultsUtil().getUserId()]
      
      HTTPUtils.defaultSession.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headders
      ).responseJSON { response in
        if response.isSuccess() {
          observer.processValue(class: User.self, response: response)
        } else {
          observer.processHTTPError(response: response)
        }
      }
      return Disposables.create()
    }
  }
}
