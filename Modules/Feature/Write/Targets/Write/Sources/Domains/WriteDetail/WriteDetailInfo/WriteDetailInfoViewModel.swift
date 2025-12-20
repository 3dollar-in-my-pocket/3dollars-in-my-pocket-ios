import Combine

import Common
import Model
import Log

extension WriteDetailInfoViewModel {
    struct Input {
        let storeName = PassthroughSubject<String, Never>()
        let selectStoreType = PassthroughSubject<SalesType, Never>()
        let didTapChangeAddress = PassthroughSubject<Void, Never>()
        let didTapNext = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeDetailInfo
        let storeName: CurrentValueSubject<String, Never>
        let storeTypes: CurrentValueSubject<SalesType, Never>
        let address: String
        let setErrorState = PassthroughSubject<Void, Never>()
        let finishWriteDetailInfo = PassthroughSubject<(storeName: String, storeType: SalesType), Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case pop
        case showErrorAelrt(Error)
        case showToast(String)
    }
    
    struct Dependency {
        let logManager: LogManagerProtocol

        init(logManager: LogManagerProtocol = LogManager.shared) {
            self.logManager = logManager
        }
    }
    
    private struct State {
        var storeName: String
        var storeType: SalesType
        var address: String
    }
    
    struct Config {
        let address: String
        let storeName: String = ""
        let storeTypes: SalesType = .road
    }
}


final class WriteDetailInfoViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    private var state: State
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(
            storeName: .init(config.storeName),
            storeTypes: .init(config.storeTypes),
            address: config.address
        )
        self.state = State(
            storeName: config.storeName,
            storeType: config.storeTypes,
            address: config.address
        )
        self.dependency = dependency

        super.init()
    }

    override func bind() {
        input.storeName
            .sink { [weak self] name in
                self?.state.storeName = name
            }
            .store(in: &cancellables)

        input.selectStoreType
            .sink { [weak self] type in
                self?.state.storeType = type
            }
            .store(in: &cancellables)

        input.didTapChangeAddress
            .sink { [weak self] in
                self?.output.route.send(.pop)
            }
            .store(in: &cancellables)

        input.didTapNext
            .sink { [weak self] in
                guard let self else { return }
                let storeName = state.storeName.trimmingCharacters(in: .whitespaces)

                guard storeName.isNotEmpty else {
                    output.route.send(.showToast(Strings.WriteDetailInfo.Toast.needStoreName))
                    output.setErrorState.send(())
                    return
                }

                sendClickNextLog()
                output.finishWriteDetailInfo.send((storeName, state.storeType))
            }
            .store(in: &cancellables)
    }

    private func sendClickNextLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .next
        ))
    }
}
