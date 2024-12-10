
import Combine

import Common
import Model
import Networking
import Log

import FirebaseRemoteConfig
import FirebaseMessaging

final class SplashViewModel: BaseViewModel {
    struct Input {
        let load = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .splash
        let advertisement = PassthroughSubject<AdvertisementResponse, Never>()
        let route = PassthroughSubject<Route, Never>()
        let showDefaultAlert = PassthroughSubject<Void, Never>()
    }
    
    enum Route {
        case goToSignIn
        case goToMain
        case goToSignInWithAlert(AlertContent)
        case showMaintenanceAlert(AlertContent)
        case showUpdateAlert
    }
    
    struct Dependency {
        var preference: Preference
        let userRepository: UserRepository
        let remoteConfigService: RemoteConfigProtocol
        let deviceRepository: DeviceRepository
        let advertisementRepository: AdvertisementRepository
        
        init(
            preference: Preference = Preference.shared,
            userRepository: UserRepository = UserRepositoryImpl(),
            remoteConfigService: RemoteConfigProtocol = RemoteConfigService(),
            deviceRepository: DeviceRepository = DeviceRepositoryImpl(),
            advertisementRepository: AdvertisementRepository = AdvertisementRepositoryImpl()
        ) {
            self.preference = preference
            self.userRepository = userRepository
            self.remoteConfigService = remoteConfigService
            self.deviceRepository = deviceRepository
            self.advertisementRepository = advertisementRepository
        }
    }
    
    let input = Input()
    let output = Output()
    private var dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }
    
    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: SplashViewModel, _) in
                owner.loadSplashAdIfExisted()
                owner.fetchAdvertisement()
                owner.checkMinimalVersion()
            }
            .store(in: &cancellables)
    }
    
    private func fetchAdvertisement() {
        Task {
            let input = FetchAdvertisementInput(position: .loading)
            let result = await dependency.advertisementRepository.fetchAdvertisements(input: input)
            
            switch result {
            case .success(let response):
                if let advertisement = response.advertisements.first {
                    dependency.preference.splashAd = advertisement
                } else {
                    dependency.preference.splashAd = nil
                }
            case .failure:
                break
            }
        }
    }
    
    private func loadSplashAdIfExisted() {
        guard let advertisement = dependency.preference.splashAd else { return }
        
        output.advertisement.send(advertisement)
    }
    
    private func checkMinimalVersion() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let minimalVersion = try await dependency.remoteConfigService.fetchMinimalVersion()
                
                if VersionUtils.isNeedUpdate(
                    currentVersion: VersionUtils.appVersion,
                    minimumVersion: minimalVersion
                ) {
                    output.route.send(.showUpdateAlert)
                } else {
                    validateToken()
                }
            } catch {
                output.showDefaultAlert.send(())
            }
        }.store(in: taskBag)
    }
    
    private func validateToken() {
        let token = dependency.preference.authToken
        
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
            let result = await dependency.userRepository.fetchUser()
            
            switch result {
            case .success(let user):
                dependency.preference.userId = user.userId
                refreshPushToken()
                
            case .failure(let error):
                handleValidationError(error: error)
            }
        }.store(in: taskBag)
    }
    
    private func refreshPushToken() {
        Task { [weak self] in
            guard let self else { return }
            
            if let pushToken = dependency.preference.fcmToken {
                let input = UserDeviceUpsertRequest(pushPlatformType: "FCM", pushToken: pushToken)
                let result = await dependency.deviceRepository.updateDevice(input: input)
                
                switch result {
                case .success(_):
                    output.route.send(.goToMain)
                case .failure(let error):
                    handleValidationError(error: error)
                }
            } else {
                output.route.send(.goToMain)
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
                output.showDefaultAlert.send(())
            }
        } else {
            output.showDefaultAlert.send(())
        }
    }
}
