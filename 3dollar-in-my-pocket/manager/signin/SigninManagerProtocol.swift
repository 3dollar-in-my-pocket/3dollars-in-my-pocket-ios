import RxSwift

protocol SigninManagerProtocol {
  
  func signin() -> Observable<SigninRequest>
}
