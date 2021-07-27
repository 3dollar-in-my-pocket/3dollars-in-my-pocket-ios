import RxSwift

protocol SigninManagerProtocol {
  
  func signIn() -> Observable<SigninRequest>
}
