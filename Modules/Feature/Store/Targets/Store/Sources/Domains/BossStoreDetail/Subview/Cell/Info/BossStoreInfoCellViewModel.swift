import UIKit
import Combine

import Common
import Model
import Log

final class BossStoreInfoCellViewModel: BaseViewModel {
    struct Input {
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let didTapCopyAccountNumber = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let info: BossStoreInfo
        let didTapSnsButton = PassthroughSubject<Void, Never>()
        let toast = PassthroughSubject<String, Never>()
    }
    
    struct Config {
        let screenName: ScreenName
        let storeId: String
        let info: BossStoreInfo
    }

    let input = Input()
    let output: Output
    let config: Config
    private let logManager: LogManagerProtocol
    
    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(info: config.info)
        self.config = config
        self.logManager = logManager
        super.init()
    }

    override func bind() {
        super.bind()
        
        input.didTapSnsButton
            .subscribe(output.didTapSnsButton)
            .store(in: &cancellables)
        
        input.didTapCopyAccountNumber
            .withUnretained(self)
            .sink { (owner: BossStoreInfoCellViewModel, _) in
                owner.sendClickCopyAccountLog()
                owner.copyAccount()
            }
            .store(in: &cancellables)
    }
    
    private func copyAccount() {
        guard let account = output.info.accountInfos.first else { return }
        UIPasteboard.general.string = "\(account.bank.description) \(account.accountNumber)"
        
        output.toast.send("🔗 계좌번호가 복사되었습니다.")
    }
}

extension BossStoreInfoCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreInfoCellViewModel: Hashable {
    static func == (lhs: BossStoreInfoCellViewModel, rhs: BossStoreInfoCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Log
private extension BossStoreInfoCellViewModel {
    func sendClickCopyAccountLog() {
        logManager.sendEvent(.init(
            screen: config.screenName,
            eventName: .clickCopyAccount,
            extraParameters: [.storeId: config.storeId]
        ))
    }
}
