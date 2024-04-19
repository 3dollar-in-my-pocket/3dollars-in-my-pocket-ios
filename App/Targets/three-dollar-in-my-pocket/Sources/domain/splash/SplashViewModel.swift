
import Combine

import Common
import Model
import Networking

import FirebaseRemoteConfig
import FirebaseMessaging

final class SplashViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let route = PassthroughSubject<Route, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    enum Route {
        case goToSignIn
        case goToMain
        case goToSignInWithAlert(AlertContent)
        case showMaintenanceAlert(AlertContent)
        case showUpdateAlert
    }
    
    let input = Input()
    let output = Output()
    
    private var userDefaults: UserDefaultsUtil
    private let userService: UserServiceProtocol
    private let remoteConfigService: RemoteConfigProtocol
    private let deviceService: DeviceServiceProtocol
    
    init(
        userDefaults: UserDefaultsUtil = UserDefaultsUtil(),
        userService: UserServiceProtocol = UserService(),
        remoteConfigService: RemoteConfigProtocol = RemoteConfigService(),
        deviceService: Networking.DeviceServiceProtocol = DeviceService()
    ) {
        self.userDefaults = userDefaults
        self.userService = userService
        self.remoteConfigService = remoteConfigService
        self.deviceService = deviceService
        
        super.init()
        
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: SplashViewModel, _) in
                owner.checkMinimalVersion()
            }
            .store(in: &cancellables)
    }
    
    private func checkMinimalVersion() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let minimalVersion = try await remoteConfigService.fetchMinimalVersion()
                
                if VersionUtils.isNeedUpdate(
                    currentVersion: VersionUtils.appVersion,
                    minimumVersion: minimalVersion
                ) {
                    output.route.send(.showUpdateAlert)
                } else {
                    validateToken()
                }
            } catch {
                output.showErrorAlert.send(error)
            }
        }.store(in: taskBag)
    }
    
    private func validateToken() {
        let token = userDefaults.authToken
        
        if validateTokenFromLocal(token: token) {
            validateTokenFromServer()
        } else {
            output.route.send(.goToSignIn)
        }
    }
    
    private func validateTokenFromLocal(token: String) -> Bool {
        return !token.isEmpty
    }
    
    private func validateTokenFromServer() {
        Task { [weak self] in
            guard let self else { return }
            let result = await userService.fetchUser()
            
            switch result {
            case .success(let user):
                userDefaults.userId = user.userId
                refreshPushToken()
                
            case .failure(let error):
                handleValidationError(error: error)
            }
        }.store(in: taskBag)
    }
    
    private func refreshPushToken() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                
                let pushToken = try await Messaging.messaging().token()
                let result = await deviceService.refreshDevice(pushToken: pushToken)
                
                switch result {
                case .success(_):
                    output.route.send(.goToMain)
                case .failure(let error):
                    handleValidationError(error: error)
                }
            } catch {
                handleValidationError(error: error)
            }
        }
        
    }
    
    private func handleValidationError(error: Error) {
        if let httpError = error as? Model.HTTPError {
            switch httpError {
            case .forbidden:
                let alertContent = AlertContent(title: nil, message: Strings.httpErrorForbidden)
                output.route.send(.goToSignInWithAlert(alertContent))
            case .unauthorized:
                let alertContent = AlertContent(title: nil, message: Strings.httpErrorUnauthorized)
                output.route.send(.goToSignInWithAlert(alertContent))
            case .maintenance:
                let alertContent = AlertContent(title: nil, message: Strings.httpErrorMaintenance)
                output.route.send(.showMaintenanceAlert(alertContent))
            default:
                output.showErrorAlert.send(error)
            }
        } else {
            output.showErrorAlert.send(error)
        }
    }
}
