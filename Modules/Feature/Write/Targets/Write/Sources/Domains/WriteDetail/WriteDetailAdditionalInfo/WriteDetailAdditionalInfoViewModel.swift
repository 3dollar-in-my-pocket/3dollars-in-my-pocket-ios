import Foundation
import Combine

import Common
import Model
import Networking

extension WriteDetailAdditionalInfoViewModel {
    struct Input {
        let didTapFinish = PassthroughSubject<Void, Never>()
        let didSelectPaymentMethod = PassthroughSubject<PaymentMethod, Never>()
        let didSelectAppearanceDay = PassthroughSubject<AppearanceDay, Never>()
        let didSelectStartTime = PassthroughSubject<Date, Never>()
        let didSelectEndTime = PassthroughSubject<Date, Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let afterCreatedStore: Bool
        let selectedPaymentMethods: CurrentValueSubject<[PaymentMethod], Never>
        let selectedDays: CurrentValueSubject<[AppearanceDay], Never>
        let selectedStartTime: CurrentValueSubject<Date?, Never>
        let selectedEndTime: CurrentValueSubject<Date?, Never>
        let finishWriteAdditionalInfo = PassthroughSubject<(
            paymentMethods: [PaymentMethod],
            appearanceDays: [AppearanceDay],
            startTime: Date?,
            endTime: Date?
        ), Never>()
        let didTapSkip = PassthroughSubject<Void, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case showErrorAlert(Error)
        case pop
    }
    
    struct State {
        var paymentMethods: [PaymentMethod]
        var appearanceDays: [AppearanceDay]
        var startTime: Date?
        var endTime: Date?
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        
        init(storeRepository: StoreRepository = StoreRepositoryImpl()) {
            self.storeRepository = storeRepository
        }
    }
    
    struct Config {
        let paymentMethods: [PaymentMethod]
        let appearanceDays: [AppearanceDay]
        let openingHours: StoreOpeningHours?
        let afterCreatedStore: Bool
        
        init(
            paymentMethods: [PaymentMethod] = [],
            appearanceDays: [AppearanceDay] = [],
            openingHours: StoreOpeningHours? = nil,
            afterCreatedStore: Bool
        ) {
            self.paymentMethods = paymentMethods
            self.appearanceDays = appearanceDays
            self.openingHours = openingHours
            self.afterCreatedStore = afterCreatedStore
        }
    }
}

final class WriteDetailAdditionalInfoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    private var state: State
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.state = State(
            paymentMethods: config.paymentMethods,
            appearanceDays: config.appearanceDays,
            startTime: config.openingHours?.startTime?.toDate(),
            endTime: config.openingHours?.endTime?.toDate()
        )
        self.output = Output(
            afterCreatedStore: config.afterCreatedStore,
            selectedPaymentMethods: .init(config.paymentMethods),
            selectedDays: .init(config.appearanceDays),
            selectedStartTime: .init(config.openingHours?.startTime?.toDate()),
            selectedEndTime: .init(config.openingHours?.endTime?.toDate())
        )
        self.dependency = dependency
        super.init()
    }
    
    override func bind() {
        super.bind()
        
        input.didTapFinish
            .sink { [weak self] _ in
                self?.handleDidTapFinish()
            }
            .store(in: &cancellables)
        
        input.didSelectPaymentMethod
            .sink { [weak self] paymentMethod in
                self?.handlePaymentMethodSelection(paymentMethod)
            }
            .store(in: &cancellables)
        
        input.didSelectAppearanceDay
            .sink { [weak self] day in
                self?.handleDaySelection(day)
            }
            .store(in: &cancellables)
        
        input.didSelectStartTime
            .sink { [weak self] time in
                self?.state.startTime = time
            }
            .store(in: &cancellables)
        
        input.didSelectEndTime
            .sink { [weak self] time in
                self?.state.endTime = time
            }
            .store(in: &cancellables)
        
        input.didTapSkip
            .subscribe(output.didTapSkip)
            .store(in: &cancellables)
    }
    
    private func handleDidTapFinish() {
        output.finishWriteAdditionalInfo.send((
            paymentMethods: state.paymentMethods,
            appearanceDays: state.appearanceDays,
            startTime: state.startTime,
            endTime: state.endTime
        ))
        
        if output.afterCreatedStore {
            output.route.send(.pop)
        }
    }
    
    private func handlePaymentMethodSelection(_ paymentMethod: PaymentMethod) {
        if state.paymentMethods.contains(paymentMethod) {
            state.paymentMethods.removeAll { $0 == paymentMethod }
        } else {
            state.paymentMethods.append(paymentMethod)
        }
    }
    
    private func handleDaySelection(_ day: AppearanceDay) {
        if state.appearanceDays.contains(day) {
            state.appearanceDays.removeAll { $0 == day }
        } else {
            state.appearanceDays.append(day)
        }
    }
}
