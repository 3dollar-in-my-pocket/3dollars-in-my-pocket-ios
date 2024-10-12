import Foundation

import Model

public protocol UserRepository {
    func signin(input: SigninRequestInput) async -> Result<SigninResponse, Error>
    
    func signup(input: SignupInput) async -> Result<SignupResponse, Error>
    
    func signinAnonymous() async -> Result<SigninResponse, Error>
    
    func fetchUser() async -> Result<UserDetailResponse, Error>
    
    func changeMarketingConsent(input: ChangeMarketingConsentInput) async -> Result<String, Error>
    
    func connectAccount(input: SigninRequestInput) async -> Result<String, Error>
    
    func signinDemo(code: String) async -> Result<SigninResponse, Error>
    
    func editUserSetting(input: UserAccountSettingPatchApiRequestInput) async -> Result<String, Error>
    
    func editUser(input: UserPatchRequestInput) async -> Result<String, Error>
    
    func logout() async -> Result<String, Error>
    
    func signout() async -> Result<String, Error>
    
    func saveMyPlace(placeType: PlaceType, input: SaveMyPlaceInput) async -> Result<Bool, Error>
    
    func getMyPlaces(placeType: PlaceType, input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PlaceResponse>, Error>
    
    func deleteMyPlace(placeType: PlaceType, placeId: String) async -> Result<Bool, Error>
}

public struct UserRepositoryImpl: UserRepository {
    public init() { }
    
    public func signin(input: SigninRequestInput) async -> Result<SigninResponse, Error> {
        let request = UserApi.signin(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signup(input: SignupInput) async -> Result<SignupResponse, Error> {
        let request = UserApi.signup(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signinAnonymous() async -> Result<SigninResponse, Error> {
        let request = UserApi.signinAnonymous
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func fetchUser() async -> Result<UserDetailResponse, Error> {
        let request = UserApi.fetchUser
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func changeMarketingConsent(input: ChangeMarketingConsentInput) async -> Result<String, Error> {
        let request = UserApi.changeMarketingConsent(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func connectAccount(input: SigninRequestInput) async -> Result<String, Error> {
        let request = UserApi.connectAccount(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signinDemo(code: String) async -> Result<SigninResponse, Error> {
        let request = UserApi.signinDemo(code: code)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editUserSetting(input: UserAccountSettingPatchApiRequestInput) async -> Result<String, Error> {
        let request = UserApi.editUserSetting(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func editUser(input: UserPatchRequestInput) async -> Result<String, Error> {
        let request = UserApi.editUser(input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func logout() async -> Result<String, Error> {
        let request = UserApi.logout
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func signout() async -> Result<String, Error> {
        let request = UserApi.signout
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func saveMyPlace(placeType: PlaceType, input: SaveMyPlaceInput) async -> Result<Bool, Error> {
        let request = UserApi.saveMyPlace(placeType: placeType, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func getMyPlaces(placeType: PlaceType, input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PlaceResponse>, Error> {
        let request = UserApi.getMyPlaces(placeType: placeType, input: input)
        
        return await NetworkManager.shared.request(requestType: request)
    }
    
    public func deleteMyPlace(placeType: PlaceType, placeId: String) async -> Result<Bool, Error> {
        let request = UserApi.deleteMyPlace(placeType: placeType, placeId: placeId)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
