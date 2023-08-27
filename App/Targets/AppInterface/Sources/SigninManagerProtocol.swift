import Combine

public protocol SigninManagerProtocol {
    func signin() -> PassthroughSubject<String, Error>
    
    func signout() -> Future<Void, Error>
    
    func logout() -> Future<Void, Error>
}
