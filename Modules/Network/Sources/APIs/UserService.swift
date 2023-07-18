import Foundation

public protocol UserServiceProtocol {
    func fetchUser() async -> Result<UserWithDeviceApiResponse, Error>
}

public struct UserService: UserServiceProtocol {
    public init() { }
    
    public func fetchUser() async -> Result<UserWithDeviceApiResponse, Error> {
        let request = FetchUserRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
