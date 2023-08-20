import Foundation

public protocol UserServiceProtocol {
    func signin(socialType: String, accessToken: String) async -> Result<SigninResponse, Error>
    
    func fetchUser() async -> Result<UserWithDeviceApiResponse, Error>
}

public struct UserService: UserServiceProtocol {
    public init() { }
    
    public func signin(socialType: String, accessToken: String) async -> Result<SigninResponse, Error> {
        let input = SigninRequestInput(socialType: socialType, token: accessToken)
        let request = SigninRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchUser() async -> Result<UserWithDeviceApiResponse, Error> {
        let request = FetchUserRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
