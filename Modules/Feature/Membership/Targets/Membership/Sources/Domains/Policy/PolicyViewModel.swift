import Combine

import Common
import Networking
import DependencyInjection
import Model
import AppInterface

final class PolicyViewModel: Common.BaseViewModel {
    struct Input {
        let onTapAllCheckButton = PassthroughSubject<Void, Never>()
        let onTapPolicyCheckButton = PassthroughSubject<Void, Never>()
        let onTapMarketingCheckButton = PassthroughSubject<Void, Never>()
        let onTapNextButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let isCheckedAll = CurrentValueSubject<Bool, Never>(false)
        let isCheckedPolicy = CurrentValueSubject<Bool, Never>(false)
        let isCheckedMarketing = CurrentValueSubject<Bool, Never>(false)
        let isEnableNextButton = CurrentValueSubject<Bool, Never>(false)
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var isCheckedAll = false
        var isCheckedPolicy = false
        var isCheckedMarketing = false
    }
    
    enum Route {
        case showErrorAlert(Error)
        case showLoading(isShow: Bool)
        case dismiss
    }
    
    let input = Input()
    let output = Output()
    private var state = State()
    private let userRepository: UserRepository
    private let deviceRepository: DeviceRepository
    private let appInterface: AppModuleInterface
    private let preference = Preference.shared
    
    init(
        userRepository: UserRepository = UserRepositoryImpl(),
        deviceRepository: DeviceRepository = DeviceRepositoryImpl(),
        appInterface: AppModuleInterface = Environment.appModuleInterface
    ) {
        self.userRepository = userRepository
        self.deviceRepository = deviceRepository
        self.appInterface = appInterface
    }
    
    override func bind() {
        input.onTapAllCheckButton
            .withUnretained(self)
            .sink { owner, _ in
                owner.state.isCheckedAll.toggle()
                owner.state.isCheckedPolicy = owner.state.isCheckedAll
                owner.state.isCheckedMarketing = owner.state.isCheckedAll
                
                owner.output.isCheckedAll.send(owner.state.isCheckedAll)
                owner.output.isCheckedPolicy.send(owner.state.isCheckedPolicy)
                owner.output.isCheckedMarketing.send(owner.state.isCheckedMarketing)
                owner.output.isEnableNextButton.send(owner.state.isCheckedAll)
            }
            .store(in: &cancellables)
        
        input.onTapPolicyCheckButton
            .withUnretained(self)
            .sink { owner, _ in
                owner.state.isCheckedPolicy.toggle()
                owner.output.isCheckedPolicy.send(owner.state.isCheckedPolicy)
                owner.output.isEnableNextButton.send(owner.state.isCheckedPolicy)
            }
            .store(in: &cancellables)
        
        input.onTapMarketingCheckButton
            .withUnretained(self)
            .sink { owner, _ in
                owner.state.isCheckedMarketing.toggle()
                owner.output.isCheckedMarketing.send(owner.state.isCheckedMarketing)
            }
            .store(in: &cancellables)
        
        input.onTapNextButton
            .withUnretained(self)
            .sink { owner, _ in
                owner.output.route.send(.showLoading(isShow: true))
                owner.registerDevice()
                owner.changeMarketingConsent(isMarketingOn: owner.state.isCheckedMarketing)
            }
            .store(in: &cancellables)
    }
    
    private func changeMarketingConsent(isMarketingOn: Bool) {
        Task {
            let marketingConsentType: MarketingConsentType = isMarketingOn ? .approve : .deny
            let input = ChangeMarketingConsentInput(marketingConsent: marketingConsentType.rawValue)
            let changeMarketingConsent = await userRepository.changeMarketingConsent(input: input)
            
            output.route.send(.showLoading(isShow: false))
            switch changeMarketingConsent {
            case .success(_):
                output.route.send(.dismiss)
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
        .store(in: taskBag)
    }
    
    private func registerDevice() {
        appInterface.getFCMToken { [weak self] token in
            guard let self = self else { return }
            Task {
                let input = UserDeviceUpsertRequest(pushPlatformType: "FCM", pushToken: token)
                return await self.deviceRepository.updateDevice(input: input)
            }
        }
    }
}
