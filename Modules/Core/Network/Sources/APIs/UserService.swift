import Foundation

import Model

public protocol UserServiceProtocol {
    func signin(socialType: String, accessToken: String) async -> Result<SigninResponse, Error>
    
    func signup(name: String, socialType: String, token: String) async -> Result<SignupResponse, Error>
    
    func signinAnonymous() async -> Result<SigninResponse, Error>
    
    func fetchUser() async -> Result<UserWithDetailApiResponse, Error>
    
    func changeMarketingConsent(marketingConsentType: String) async -> Result<String, Error>
    
    func connectAccount(socialType: String, accessToken: String) async -> Result<String, Error>
    
    func signinDemo(code: String) async -> Result<SigninResponse, Error>
    
    func editUserSetting(enableActivityNotification: Bool, marketingConsent: MarketingConsent) async -> Result<String, Error>
    
    func editUser(nickname: String?, representativeMedalId: Int?) async -> Result<String, Error>
    
    func logout() async -> Result<String, Error>
    
    func signout() async -> Result<String, Error>
    
    func saveMyPlace(placeType: PlaceType, input: SaveMyPlaceInput) async -> Result<Bool, Error>
    func deleteMyPlace(placeType: PlaceType, placeId: String) async -> Result<Bool, Error>
}

public struct UserService: UserServiceProtocol {
    public init() { }
    
    public func signin(socialType: String, accessToken: String) async -> Result<SigninResponse, Error> {
        let input = SigninRequestInput(socialType: socialType, token: accessToken)
        let request = SigninRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signup(name: String, socialType: String, token: String) async -> Result<SignupResponse, Error> {
        let input = SignupInput(name: name, socialType: socialType, token: token)
        let request = SignupRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signinAnonymous() async -> Result<SigninResponse, Error> {
        let request = SigninAnonymousRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchUser() async -> Result<UserWithDetailApiResponse, Error> {
        let request = FetchMyUserRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func changeMarketingConsent(marketingConsentType: String) async -> Result<String, Error> {
        let input = ChangeMarketingConsentInput(marketingConsent: marketingConsentType)
        let request = ChangeMarketingConsentRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func connectAccount(socialType: String, accessToken: String) async -> Result<String, Error> {
        let input = SigninRequestInput(socialType: socialType, token: accessToken)
        let request = ConnectAccountRequest(requestInput: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signinDemo(code: String) async -> Result<SigninResponse, Error> {
        let request = SigninDemoRequest(code: code)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editUserSetting(enableActivityNotification: Bool, marketingConsent: MarketingConsent) async -> Result<String, Error> {
        let input = UserAccountSettingPatchApiRequestInput(
            enableActivitiesPush: enableActivityNotification,
            marketingConsent: marketingConsent
        )
        let request = EditUserSettingRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editUser(nickname: String?, representativeMedalId: Int?) async -> Result<String, Error> {
        let input = UserPatchRequestInput(name: nickname, representativeMedalId: representativeMedalId)
        let request = EditUserRequest(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func logout() async -> Result<String, Error> {
        let request = LogoutRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signout() async -> Result<String, Error> {
        let request = SignoutRequest()
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func saveMyPlace(placeType: PlaceType, input: SaveMyPlaceInput) async -> Result<Bool, Error> {
        let request = SaveMyPlaceRequest(placeType: placeType, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func deleteMyPlace(placeType: PlaceType, placeId: String) async -> Result<Bool, Error> {
        let request = DeleteMyPlaceRequest(placeType: placeType, placeId: placeId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
