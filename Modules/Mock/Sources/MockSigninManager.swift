import Foundation
import Combine

import AppInterface

final class MockSigninManager: SigninManagerProtocol {
    func signin() -> PassthroughSubject<String, Error> {
        return .init()
    }
    
    func signout() -> Future<Void, Error> {
        return .init { future in
            future(.success(()))
        }
    }
    
    func logout() -> Future<Void, Error> {
        return .init { future in
            future(.success(()))
        }
    }
}
