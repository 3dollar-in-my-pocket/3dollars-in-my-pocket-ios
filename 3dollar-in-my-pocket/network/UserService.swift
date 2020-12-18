import Alamofire
import RxSwift

protocol UserServiceProtocol {
  
  func validateToken(token: String) -> Observable<String>
  
  func signIn(user: User) -> Observable<SignIn>
  
  func setNickname(
    nickname: String,
    id: Int,
    token: String
  ) -> Observable<Void>
  
  func getUserInfo(userId: Int) -> Observable<User>
  
  func withdrawal(userId: Int) -> Observable<Void>
}

struct UserService: UserServiceProtocol {
  
  func validateToken(token: String) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/me"
      let headers = HTTPUtils.defaultHeader()
      
      AF.request(
        urlString,
        method: .get,
        headers: headers
      ).responseString { response in
        if response.isSuccess() {
          observer.onNext("success")
          observer.onCompleted()
        } else {
          if let statusCode = response.response?.statusCode {
            observer.processHTTPError(statusCode: statusCode)
          } else {
            let error = CommonError(desc: "알수 없는 오류발생.\n잠시 후 다시 시도해주세요.")
            
            observer.onError(error)
          }
        }
      }
      
      return Disposables.create()
    }
  }
  
  func signIn(user: User) -> Observable<SignIn> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/login"
      let parameters = user.toDict()
      
      AF.request(
        urlString,
        method: .post,
        parameters: parameters,
        encoding: JSONEncoding.default,
        headers: HTTPUtils.jsonHeader()
      ).responseJSON { response in
        Log.debug("response: \(response)")
        if let value = response.value {
          if let signIn: SignIn = JsonUtils.toJson(object: value) {
            observer.onNext(signIn)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Value is nil")
          
          observer.onError(error)
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
      let headers = ["Authorization": token] as HTTPHeaders
      
      AF.request(
        urlString,
        method: .put,
        parameters: parameters,
        headers: headers
      ).responseString(completionHandler: { (response) in
        if let statusCode = response.response?.statusCode {
          if statusCode == 200 {
            observer.onNext(())
            observer.onCompleted()
          } else if statusCode == 400{
            let error = CommonError(desc: "이미 존재하는 닉네임입니다.")
            
            observer.onError(error)
          } else {
            let error = CommonError(desc: "알 수 없는 에러입니다.")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Status code is nil")
          
          observer.onError(error)
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
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headders
      ).responseJSON { response in
        if let value = response.value {
          if let user: User = JsonUtils.toJson(object: value) {
            observer.onNext(user)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Value is nil")
          
          observer.onError(error)
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
      
      AF.request(
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
          } else {
            let error = CommonError(desc: "알 수 없는 에러입니다.")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Status code is nil")
          
          observer.onError(error)
        }
      })
      
      return Disposables.create()
    }
  }
  
  static func changeNickname(nickname: String) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/nickname"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = [
        "nickName": nickname,
        "userId": UserDefaultsUtil.getUserId() ?? ""
      ]
      
      AF.request(
        urlString,
        method: .put,
        parameters: parameters,
        headers: headers
      ).responseString(completionHandler: { response in
        if let statusCode = response.response?.statusCode {
          if statusCode == 200 {
            observer.onNext("success")
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "이미 존재하는 닉네임입니다.")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Status code is nil")
          
          observer.onError(error)
        }
      })
      
      return Disposables.create()
    }
  }
  
  // 마이페이지 > 닉네임 변경 API와 따로 구현
  // 초기 닉네임 설정하는 화면에서는 토큰과 id가 UserDefault에 저장되어있으면 안되기 떄문에 입력값으로 받음
  static func setNickname(
    nickname: String,
    id: Int,
    token: String
  ) -> Observable<String> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/nickname"
      let headers = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["nickName": nickname, "userId": id]
      
      AF.request(
        urlString,
        method: .put,
        parameters: parameters,
        headers: headers
      ).responseString(completionHandler: { response in
        if let statusCode = response.response?.statusCode {
          if statusCode == 200 {
            observer.onNext("success")
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "이미 존재하는 닉네임입니다.")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Status code is nil")
          
          observer.onError(error)
        }
      })
      return Disposables.create()
    }
  }
  
  static func getUserInfo() -> Observable<User> {
    return Observable.create { observer -> Disposable in
      let urlString = HTTPUtils.url + "/api/v1/user/info"
      let headders = HTTPUtils.defaultHeader()
      let parameters: [String: Any] = ["userId" : UserDefaultsUtil().getUserId()]
      
      AF.request(
        urlString,
        method: .get,
        parameters: parameters,
        headers: headders
      ).responseJSON { response in
        if let value = response.value {
          if let user: User = JsonUtils.toJson(object: value) {
            observer.onNext(user)
            observer.onCompleted()
          } else {
            let error = CommonError(desc: "failed to json")
            
            observer.onError(error)
          }
        } else {
          let error = CommonError(desc: "Value is nil")
          
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
}
