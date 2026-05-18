import UIKit
import Combine

import Common
import DesignSystem
import Model
import Networking
import Log

final class StoreDetailVisitInducementModalViewModel: BaseViewModel {
    struct Input {
        let didTapVisit = PassthroughSubject<VisitType, Never>()
        let didImpression = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let title: String
        let subtitle: String
        let openedButtonTitle: String
        let closedButtonTitle: String

        let isInteractable = CurrentValueSubject<Bool, Never>(true)
        let onSuccessVisit = PassthroughSubject<String, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }

    struct Config {
        let storeId: Int
    }

    struct State {
        var isInProgress: Bool = false
    }

    struct Dependency {
        let visitRepository: VisitRepository
        let logManager: LogManagerProtocol

        init(
            visitRepository: VisitRepository = VisitRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.visitRepository = visitRepository
            self.logManager = logManager
        }
    }

    let input = Input()
    let output: Output
    private let config: Config
    private var state = State()
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        self.output = Output(
            title: Strings.VisitInducementModal.title,
            subtitle: Strings.VisitInducementModal.subtitle,
            openedButtonTitle: Strings.VisitInducementModal.opened,
            closedButtonTitle: Strings.VisitInducementModal.closed
        )
        super.init()
    }

    override func bind() {
        super.bind()

        input.didTapVisit
            .withUnretained(self)
            .sink { (owner, type: VisitType) in
                guard !owner.state.isInProgress else { return }
                owner.state.isInProgress = true
                owner.output.isInteractable.send(false)
                owner.sendClickVisitLog(type: type)
                owner.visitStore(type: type)
            }
            .store(in: &cancellables)

        input.didImpression
            .withUnretained(self)
            .sink { (owner, _) in
                owner.sendImpressionLog()
            }
            .store(in: &cancellables)
    }

    private func visitStore(type: VisitType) {
        Task { [weak self] in
            guard let self else { return }
            let request = VisitStoreRequestInput(storeId: config.storeId, visitType: type)
            let result = await dependency.visitRepository.visitStore(input: request)

            switch result {
            case .success:
                output.onSuccessVisit.send(Strings.DisplayItemModal.thanksToast)
            case .failure(let error):
                state.isInProgress = false
                output.isInteractable.send(true)
                output.showErrorAlert.send(error)
            }
        }
    }
}

// MARK: Log
extension StoreDetailVisitInducementModalViewModel {
    private func sendImpressionLog() {
        dependency.logManager.sendEvent(event: ImpressionEvent(
            screen: .storeDetail,
            objectType: .banner,
            objectId: .visitInducementModal,
            extraParameters: [.storeId: config.storeId]
        ))
    }

    private func sendClickVisitLog(type: VisitType) {
        let value: LogObjectId
        switch type {
        case .exists:
            value = .visitSuccess
        case .notExists:
            value = .visitFail
        case .unknown:
            return
        }

        dependency.logManager.sendEvent(event: ClickEvent(
            screen: .storeDetail,
            objectType: .button,
            objectId: .visitInducementModal,
            extraParameters: [
                .storeId: config.storeId,
                .value: value
            ]
        ))
    }
}
