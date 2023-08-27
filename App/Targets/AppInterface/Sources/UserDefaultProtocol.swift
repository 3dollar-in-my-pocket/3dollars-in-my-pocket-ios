public protocol UserDefaultProtocol {
    var authToken: String { get set }
    
    var userId: Int { get set }
    
    var isAnonymousUser: Bool { get set }
}
