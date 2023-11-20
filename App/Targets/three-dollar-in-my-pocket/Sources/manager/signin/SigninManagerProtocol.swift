import RxSwift

import Model

protocol SigninManagerProtocol {
    func signin() -> Observable<SigninRequest>
    
    func signout() -> Observable<Void>
    
    func logout() -> Observable<Void>
}
