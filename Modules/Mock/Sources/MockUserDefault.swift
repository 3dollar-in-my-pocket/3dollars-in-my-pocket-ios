import Foundation

import AppInterface

public final class MockUserDefault: UserDefaultProtocol {
    public var authToken: String
    
    public var userId: Int
    
    public var isAnonymousUser: Bool
    
    public init(authToken: String = "", userId: Int = 0, isAnonymousUser: Bool = false) {
        self.authToken = authToken
        self.userId = userId
        self.isAnonymousUser = isAnonymousUser
    }
}
