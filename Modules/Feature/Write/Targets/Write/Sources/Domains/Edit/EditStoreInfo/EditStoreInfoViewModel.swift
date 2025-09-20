import Foundation
import Combine

import Common
import Model

extension EditStoreInfoViewModel {
    struct Input {
        let storeName = PassthroughSubject<String, Never>()
        let selectStoreType = PassthroughSubject<SalesType, Never>()
        let selectPaymentMethod = PassthroughSubject<PaymentMethod, Never>()
        let selectAppearanceDay = PassthroughSubject<AppearanceDay, Never>()
        let selectStartTime = PassthroughSubject<Date, Never>()
        let selectEndTime = PassthroughSubject<Date, Never>()
        let didTapSave = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let store: CurrentValueSubject<UserStoreResponse, Never>
        let nameFieldState = PassthroughSubject<NameTextField.State, Never>()
        let editedStoreInfo = PassthroughSubject<UserStoreResponse, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pop
        case showToast(String)
    }
    
    struct Config {
        let store: UserStoreResponse
    }
    
    struct State {
        var store: UserStoreResponse
    }
}

final class EditStoreInfoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    private var state: State
    
    init(config: Config) {
        self.state = State(store: config.store)
        self.output = Output(store: .init(config.store))
        super.init()
    }
    
    override func bind() {
        input.storeName
            .sink { [weak self] name in
                self?.state.store.name = name
            }
            .store(in: &cancellables)
        
        input.selectStoreType
            .sink { [weak self] type in
                self?.state.store.salesTypeV2?.type = type
            }
            .store(in: &cancellables)
        
        input.selectPaymentMethod
            .sink { [weak self] method in
                guard let self = self else { return }
                
                if state.store.paymentMethods.contains(method) {
                    state.store.paymentMethods.removeAll(where:  { $0 == method})
                } else {
                    state.store.paymentMethods.append(method)
                }
            }
            .store(in: &cancellables)
        
        input.selectAppearanceDay
            .sink { [weak self] day in
                guard let self = self else { return }
                if state.store.appearanceDays.contains(day) {
                    state.store.appearanceDays.removeAll(where: { $0 == day })
                } else {
                    state.store.appearanceDays.append(day)
                }
            }
            .store(in: &cancellables)
        
        input.selectStartTime
            .sink { [weak self] time in
                self?.state.store.openingHours?.startTime = time.toString(format: "HH:mm")
            }
            .store(in: &cancellables)
        
        input.selectEndTime
            .sink { [weak self] time in
                self?.state.store.openingHours?.endTime = time.toString(format: "HH:mm")
            }
            .store(in: &cancellables)
        
        input.didTapSave
            .sink { [weak self] _ in
                self?.saveStoreInfo()
            }
            .store(in: &cancellables)
    }
    
    private func saveStoreInfo() {
        guard state.store.name.isNotEmpty else {
            output.route.send(.showToast("가게 이름을 입력해주세요."))
            output.nameFieldState.send(.error)
            return
        }
        
        output.editedStoreInfo.send(state.store)
        output.route.send(.pop)
    }
}
