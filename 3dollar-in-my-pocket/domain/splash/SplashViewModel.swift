import RxSwift
import RxCocoa
import FirebaseRemoteConfig

final class SplashViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PublishSubject<Void>()
    }
    
    struct Output {
        let goToSignIn = PublishRelay<Void>()
        let goToMain = PublishRelay<Void>()
        let goToSignInWithAlert = PublishRelay<AlertContent>()
        let showMaintenanceAlert = PublishRelay<AlertContent>()
        let showUpdateAlert = PublishRelay<Void>()
    }
    
    let input = Input()
    let output = Output()
    var userDefaults: UserDefaultsUtil
    let userService: UserServiceProtocol
    let remoteConfigService: RemoteConfigProtocol
    let metaContext: MetaContext
    let medalService: MedalServiceProtocol
    private let feedbackService: FeedbackServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let deviceService: DeviceServiceProtocol
    
    init(
        userDefaults: UserDefaultsUtil,
        userService: UserServiceProtocol,
        remoteConfigService: RemoteConfigProtocol,
        metaContext: MetaContext,
        medalService: MedalServiceProtocol,
        feedbackService: FeedbackServiceProtocol,
        categoryService: CategoryServiceProtocol,
        deviceService: DeviceServiceProtocol
    ) {
        self.userDefaults = userDefaults
        self.userService = userService
        self.remoteConfigService = remoteConfigService
        self.metaContext = metaContext
        self.medalService = medalService
        self.feedbackService = feedbackService
        self.categoryService = categoryService
        self.deviceService = deviceService
        
        super.init()
        
        self.input.viewDidLoad
            .bind(onNext: { [weak self] in
                self?.fetchBossStoreTypes()
                self?.fetchMedals()
                self?.fetchStreetFoodCategories()
                self?.fetchFoodTurckCategories()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func checkMinimalVersion() {
        self.remoteConfigService.fetchMinimalVersion()
            .subscribe(onNext: { [weak self] minimalVersion in
                if VersionUtils.isNeedUpdate(
                    currentVersion: VersionUtils.appVersion,
                    minimumVersion: minimalVersion
                ) {
                    self?.output.showUpdateAlert.accept(())
                } else {
                    self?.validateToken()
                }
            },
            onError: self.showErrorAlert.accept(_:))
            .disposed(by: self.disposeBag)
    }
    
    private func validateToken() {
        let token = self.userDefaults.authToken
        
        if self.validateTokenFromLocal(token: token) {
            self.validateTokenFromServer()
        } else {
            self.output.goToSignIn.accept(())
        }
    }
    
    private func validateTokenFromLocal(token: String) -> Bool {
        return !token.isEmpty
    }
    
    private func validateTokenFromServer() {
        self.userService.fetchUserInfo()
            .do(onNext: { [weak self] userInfoResponse in
                self?.userDefaults.userId = userInfoResponse.userId
            })
            .map { _ in Void() }
            .subscribe(
                onNext: self.refreshPushToken,
                onError: self.handelValidationError(error:)
            )
            .disposed(by: disposeBag)
    }
    
    private func refreshPushToken() {
        self.deviceService.getFCMToken()
            .flatMap { [weak self] pushToken -> Observable<String> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                return self.deviceService.refreshDeivce(
                    pushPlatformType: .fcm,
                    pushToken: pushToken
                )
            }
            .subscribe(onNext: { [weak self] _ in
                self?.output.goToMain.accept(())
            }) { error in
                self.handelValidationError(error: error)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func handelValidationError(error: Error) {
        if let httpError = error as? HTTPError {
            switch httpError {
            case .forbidden, .unauthorized:
                let alertContent = AlertContent(title: nil, message: httpError.description)
                
                self.output.goToSignInWithAlert.accept(alertContent)
            case .maintenance:
                let alertContent = AlertContent(title: nil, message: httpError.description)
                
                self.output.showMaintenanceAlert.accept(alertContent)
            default:
                self.showErrorAlert.accept(error)
            }
        } else {
            self.showErrorAlert.accept(error)
        }
    }
    
    private func fetchMedals() {
        self.medalService.fetchMedals()
            .map { $0.map(Medal.init) }
            .subscribe(onNext: { [weak self] medals in
                self?.metaContext.medals = medals
                self?.checkMinimalVersion()
            }, onError: { [weak self] error in
                self?.showErrorAlert.accept(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchBossStoreTypes() {
        self.feedbackService.fetchFeedbackTypes(storeType: .foodTruck)
            .subscribe(onNext: { [weak self] feedbackTypes in
                self?.metaContext.feedbackTypes = feedbackTypes
            }, onError: { [weak self] error in
                self?.showErrorAlert.accept(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchStreetFoodCategories() {
        self.categoryService.fetchStreetFoodCategories()
            .subscribe(onNext: { [weak self] categories in
                self?.metaContext.streetFoodCategories = categories
            }, onError: { [weak self] error in
                self?.showErrorAlert.accept(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func fetchFoodTurckCategories() {
        self.categoryService.fetchFoodTruckCategories()
            .subscribe(onNext: { [weak self] categories in
                self?.metaContext.foodTruckCategories = categories
            }, onError: { [weak self] error in
                self?.showErrorAlert.accept(error)
            })
            .disposed(by: self.disposeBag)
    }
}
