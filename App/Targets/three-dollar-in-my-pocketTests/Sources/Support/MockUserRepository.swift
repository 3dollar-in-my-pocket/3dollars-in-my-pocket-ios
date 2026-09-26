import Foundation

import Model
import Networking

final class MockUserRepository: UserRepository {
    var fetchUserResult: Result<UserDetailResponse, Error> = .failure(MockError.notStubbed())

    func signin(input: SigninRequestInput) async -> Result<SigninResponse, Error> { .failure(MockError.notStubbed()) }
    func signup(input: SignupInput) async -> Result<SignupResponse, Error> { .failure(MockError.notStubbed()) }
    func signupWithRandomName(input: SignupInput) async -> Result<SignupResponse, Error> { .failure(MockError.notStubbed()) }
    func signinAnonymous() async -> Result<SigninResponse, Error> { .failure(MockError.notStubbed()) }
    func fetchUser() async -> Result<UserDetailResponse, Error> { fetchUserResult }
    func changeMarketingConsent(input: ChangeMarketingConsentInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func connectAccount(input: SigninRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func signinDemo(code: String) async -> Result<SigninResponse, Error> { .failure(MockError.notStubbed()) }
    func editUserSetting(input: UserAccountSettingPatchApiRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func editUser(input: UserPatchRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func logout(input: UserLogOutRequestInput) async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func signout() async -> Result<String, Error> { .failure(MockError.notStubbed()) }
    func saveMyPlace(placeType: PlaceType, input: SaveMyPlaceInput) async -> Result<Bool, Error> { .failure(MockError.notStubbed()) }
    func getMyPlaces(placeType: PlaceType, input: CursorRequestInput) async -> Result<ContentsWithCursorResponse<PlaceResponse>, Error> { .failure(MockError.notStubbed()) }
    func deleteMyPlace(placeType: PlaceType, placeId: String) async -> Result<Bool, Error> { .failure(MockError.notStubbed()) }
    func createRandomName() async -> Result<ContentListUserNameResponse, Error> { .failure(MockError.notStubbed()) }
}
