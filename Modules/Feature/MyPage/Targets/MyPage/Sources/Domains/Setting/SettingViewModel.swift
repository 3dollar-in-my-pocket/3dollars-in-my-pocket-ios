import Foundation
import UIKit
import Combine

import Common
import Model
import Networking
import AppInterface

public final class SettingViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let didTapEditNickname = PassthroughSubject<Void, Never>()
        let didTapAdBanner = PassthroughSubject<SettingAdBannerType, Never>()
        let toggleNotification = PassthroughSubject<NotificationType, Never>()
        let didTapCell = PassthroughSubject<SettingCellType, Never>()
        let logout = PassthroughSubject<Void, Never>()
        let signout = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let cellTypes = PassthroughSubject<[SettingCellType], Never>()
        let showToast = PassthroughSubject<String, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    private struct State {
        var user: UserWithDetailApiResponse?
    }
    
    enum Route {
        case pushEditNickname(EditNicknameViewModel)
        case pushQna
        case pushAgreement
        case pushTeamInfo
        case goToSignin
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private var userDefaults: UserDefaultProtocol = Environment.appModuleInterface.userDefaults
    private var userService: UserServiceProtocol
    private let globalEventBus: GlobalEventBusProtocol = Environment.appModuleInterface.globalEventBus
    
    
    public init(
        userService: UserServiceProtocol = UserService()
    ) {
        self.userService = userService
    }
    
    public override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: SettingViewModel, _) in
                owner.fetchUser()
            }
            .store(in: &cancellables)
        
        input.didTapEditNickname
            .withUnretained(self)
            .sink { (owner: SettingViewModel, _) in
                owner.pushEditNickname()
            }
            .store(in: &cancellables)
        
        input.didTapAdBanner
            .withUnretained(self)
            .sink { (owner: SettingViewModel, type: SettingAdBannerType) in
                guard let url = URL(string: type.url) else { return }
                UIApplication.shared.open(url)
            }
            .store(in: &cancellables)
        
        input.toggleNotification
            .withUnretained(self)
            .sink { (owner: SettingViewModel, type: NotificationType) in
                owner.editNotification(type: type)
            }
            .store(in: &cancellables)
        
        input.didTapCell
            .withUnretained(self)
            .sink { (owner: SettingViewModel, cellType: SettingCellType) in
                switch cellType {
                case .account, .activityNotification, .marketingNotification, .signout:
                    break
                case .qna:
                    owner.output.route.send(.pushQna)
                case .agreement:
                    owner.output.route.send(.pushAgreement)
                case .teamInfo:
                    owner.output.route.send(.pushTeamInfo)
                }
            }
            .store(in: &cancellables)
        
        input.logout
            .withUnretained(self)
            .sink { (owner: SettingViewModel, _) in
                owner.logout()
            }
            .store(in: &cancellables)
        
        input.signout
            .withUnretained(self)
            .sink { (owner: SettingViewModel, _) in
                owner.signout()
            }
            .store(in: &cancellables)
        
        globalEventBus.onEditNickname
            .withUnretained(self)
            .sink { (owner: SettingViewModel, nickname: String) in
                owner.state.user?.name = nickname
                
                guard let user = owner.state.user else { return }
                owner.output.cellTypes.send(owner.createCellTypes(user: user))
            }
            .store(in: &cancellables)
    }
    
    private func fetchUser() {
        Task {
            let response = await userService.fetchUser()
            
            switch response {
            case .success(let userResponse):
                state.user = userResponse
                output.cellTypes.send(createCellTypes(user: userResponse))
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
        .store(in: taskBag)
    }
    
    private func createCellTypes(user: UserWithDetailApiResponse) -> [SettingCellType] {
        let socialType = SocialType(value: user.socialType ?? "")
        let isEnableMarketingConsent = MarketingConsent(value: user.settings.marketingConsent) == .approve
        
        return [
            .account(name: user.name, socialType: socialType),
            .activityNotification(isOn: user.settings.enableActivitiesPush),
            .marketingNotification(isOn: isEnableMarketingConsent),
            .qna,
            .agreement,
            .teamInfo,
            .signout
        ]
    }
    
    private func pushEditNickname() {
        guard let nickname = state.user?.name else { return }
        let config = EditNicknameViewModel.Config(nickname: nickname)
        let viewModel = EditNicknameViewModel(config: config)
        
        output.route.send(.pushEditNickname(viewModel))
    }
    
    private func editNotification(type: NotificationType) {
        guard let user = state.user else { return }
        
        let enableActivitiesPush: Bool
        let marketingConsent: MarketingConsent
        
        switch type {
        case .activity(let isOn):
            enableActivitiesPush = isOn
            marketingConsent = MarketingConsent(value: user.settings.marketingConsent)
        case .marketing(let isOn):
            enableActivitiesPush = user.settings.enableActivitiesPush
            marketingConsent = isOn ? .approve : .deny
        }
        
        Task {
            let result = await userService.editUserSetting(
                enableActivityNotification: enableActivitiesPush,
                marketingConsent: marketingConsent
            )
            
            switch result {
            case .success(_):
                showSuccessToast(type: type)
                updateNotification(type: type)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
        .store(in: taskBag)
    }
    
    private func showSuccessToast(type: NotificationType) {
        switch type {
        case .activity(let isOn):
            let message = isOn ? Strings.Setting.ActivityNotification.on : Strings.Setting.ActivityNotification.off
            output.showToast.send(message)
        case .marketing(let isOn):
            let message = isOn ? Strings.Setting.MarketingNotification.on : Strings.Setting.MarketingNotification.off
            output.showToast.send(message)
        }
    }
    
    private func updateNotification(type: NotificationType) {
        switch type {
        case .activity(let isOn):
            state.user?.settings.enableActivitiesPush = isOn
        case .marketing(let isOn):
            state.user?.settings.marketingConsent = isOn ? MarketingConsent.approve.rawValue : MarketingConsent.deny.rawValue
        }
    }
    
    private func logout() {
        guard let socialType = state.user?.socialType else { return }
        
        Task {
            await userService.logout()
        }
        .store(in: taskBag)
        
        switch SocialType(value: socialType) {
        case .apple:
            Environment.appModuleInterface.appleSigninManager.logout()
                .sink { _ in
                    
                } receiveValue: { [weak self] _ in
                    self?.clearUserDefaults()
                    self?.output.route.send(.goToSignin)
                }
                .store(in: &cancellables)
        case .kakao:
            Environment.appModuleInterface.kakaoSigninManager.logout().sink { _ in
                
            } receiveValue: { [weak self] _ in
                self?.clearUserDefaults()
                self?.output.route.send(.goToSignin)
            }
            .store(in: &cancellables)
        case .google, .unknown:
            break
        }
    }
    
    private func signout() {
        guard let socialType = state.user?.socialType else { return }
        
        Task {
            await userService.signout()
        }
        .store(in: taskBag)
        
        switch SocialType(value: socialType) {
        case .apple:
            Environment.appModuleInterface.appleSigninManager.signout()
                .sink { _ in
                    
                } receiveValue: { [weak self] _ in
                    self?.clearUserDefaults()
                    self?.output.route.send(.goToSignin)
                }
                .store(in: &cancellables)
        case .kakao:
            Environment.appModuleInterface.kakaoSigninManager.signout().sink { _ in
                
            } receiveValue: { [weak self] _ in
                self?.clearUserDefaults()
                self?.output.route.send(.goToSignin)
            }
            .store(in: &cancellables)
        case .google, .unknown:
            break
        }
    }
    
    private func clearUserDefaults() {
        userDefaults.authToken = ""
        userDefaults.userId = -1
    }
}
