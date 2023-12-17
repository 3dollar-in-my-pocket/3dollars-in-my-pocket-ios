import Foundation

import AppInterface

struct MockUserDefault: UserDefaultProtocol {
    var authToken: String = ""
    
    var userId: Int = 0
    
    var isAnonymousUser: Bool = false
}
