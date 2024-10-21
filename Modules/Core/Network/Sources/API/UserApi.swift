import Foundation

import Model

enum UserApi {
    case signin(input: SigninRequestInput)
    case signup(input: SignupInput)
    case signinAnonymous
    case fetchUser
    case changeMarketingConsent(input: ChangeMarketingConsentInput)
    case connectAccount(input: SigninRequestInput)
    case signinDemo(code: String)
    case editUserSetting(input: UserAccountSettingPatchApiRequestInput)
    case editUser(input: UserPatchRequestInput)
    case logout
    case signout
    case saveMyPlace(placeType: PlaceType, input: SaveMyPlaceInput)
    case getMyPlaces(placeType: PlaceType, input: CursorRequestInput)
    case deleteMyPlace(placeType: PlaceType, placeId: String)
}

extension UserApi: RequestType {
    var param: Encodable? {
        switch self {
        case .signin(let input):
            return input
        case .signup(let input):
            return input
        case .signinAnonymous:
            return nil
        case .fetchUser:
            return ["includeActivities": true]
        case .changeMarketingConsent(let input):
            return input
        case .connectAccount(let input):
            return input
        case .signinDemo(let code):
            return ["code": code]
        case .editUserSetting(let input):
            return input
        case .editUser(let input):
            return input
        case .logout:
            return nil
        case .signout:
            return nil
        case .saveMyPlace(_, let input):
            return input
        case .getMyPlaces(_, let input):
            return input
        case .deleteMyPlace(_, let placeId):
            return ["placeId": placeId]
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .signin:
            return .post
        case .signup:
            return .post
        case .signinAnonymous:
            return .post
        case .fetchUser:
            return .get
        case .changeMarketingConsent:
            return .put
        case .connectAccount:
            return .put
        case .signinDemo:
            return .post
        case .editUserSetting:
            return .patch
        case .editUser:
            return .patch
        case .logout:
            return .post
        case .signout:
            return .delete
        case .saveMyPlace:
            return .post
        case .getMyPlaces:
            return .get
        case .deleteMyPlace:
            return .delete
        }
    }
    
    var header: HTTPHeaderType {
        switch self {
        case .signin:
            return .json
        case .signup:
            return .json
        case .signinAnonymous:
            return .json
        case .fetchUser:
            return .json
        case .changeMarketingConsent:
            return .json
        case .connectAccount:
            return .json
        case .signinDemo:
            return .json
        case .editUserSetting:
            return .json
        case .editUser:
            return .json
        case .logout:
            return .json
        case .signout:
            return .json
        case .saveMyPlace:
            return .json
        case .getMyPlaces:
            return .json
        case .deleteMyPlace:
            return .json
        }
    }
    
    var path: String {
        switch self {
        case .signin:
            return "/api/v2/login"
        case .signup:
            return "/api/v2/signup"
        case .signinAnonymous:
            return "/api/v1/signup/anonymous"
        case .fetchUser:
            return "/api/v4/my/user"
        case .changeMarketingConsent:
            return "/api/v1/user/me/marketing-consent"
        case .connectAccount:
            return "/api/v1/connect/account"
        case .signinDemo:
            return "/api/login/demo"
        case .editUserSetting:
            return "/api/v4/my/user-settings"
        case .editUser:
            return "/api/v4/my/user"
        case .logout:
            return "/api/v2/logout"
        case .signout:
            return "/api/v2/signout"
        case .saveMyPlace(let placeType, _):
            return "/api/v1/my/\(placeType.rawValue)/place"
        case .getMyPlaces(let placeType, _):
            return "/api/v1/my/\(placeType.rawValue)/places"
        case .deleteMyPlace(let placeType, let placeId):
            return "/api/v1/my/\(placeType.rawValue)/place/\(placeId)"
        }
    }
    
    var usingQuery: Bool {
        switch self {
        case .signinDemo, .fetchUser:
            return true
        default:
            return false
        }
    }
}
