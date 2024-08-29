import Combine

import Common
import Networking
import Model
import Log

final class ReportBottomSheetViewModel: BaseViewModel {
    struct Input {
        let didTapReason = PassthroughSubject<Int, Never>()
        let didTapReport = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .reportStore
        let reportReasons: [ReportReason]
        let isEnableReport = CurrentValueSubject<Bool, Never>(false)
        let dismissWithPop = PassthroughSubject<Void, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct State {
        var selectedReasone: ReportReason?
    }
    
    struct Config {
        let storeId: Int
        let reportReasons: [ReportReason]
    }
    
    let input = Input()
    let output: Output
    private let config: Config
    private var state = State()
    private let storeRepository: StoreRepository
    private let logManager: LogManagerProtocol
    
    init(
        config: Config,
        storeRespository: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared
    ) {
        self.output = Output(reportReasons: config.reportReasons)
        self.config = config
        self.storeRepository = storeRespository
        self.logManager = logManager
        
        super.init()
    }
    
    override func bind() {
        input.didTapReason
            .withUnretained(self)
            .sink { (owner: ReportBottomSheetViewModel, index) in
                guard let reason = owner.output.reportReasons[safe: index] else { return }
                
                owner.state.selectedReasone = reason
                owner.output.isEnableReport.send(true)
            }
            .store(in: &cancellables)
        
        input.didTapReport
            .withUnretained(self)
            .sink { (owner: ReportBottomSheetViewModel, _) in
                guard let reason = owner.state.selectedReasone else { return }
                owner.reportStore(reason: reason)
                owner.sendClickReportLog(reason: reason)
            }
            .store(in: &cancellables)
    }
    
    private func reportStore(reason: ReportReason) {
        Task {
            let reportResult = await storeRepository.reportStore(storeId: config.storeId, reportReason: reason.type)
            
            switch reportResult {
            case .success(_):
                output.dismissWithPop.send(())
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}

// MARK: Log
extension ReportBottomSheetViewModel {
    private func sendClickReportLog(reason: ReportReason) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickReport,
            extraParameters: [
                .storeId: config.storeId,
                .value: reason.description
            ]))
    }
}
