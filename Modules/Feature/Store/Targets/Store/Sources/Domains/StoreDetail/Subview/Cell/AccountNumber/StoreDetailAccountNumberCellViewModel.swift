import UIKit
import Combine

import Common
import Model

extension StoreDetailAccountNumberCellViewModel {
    struct Input {
        let didTapCopyAccountNumber = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let data: StoreAccountNumberSectionResponse
        let showToast = PassthroughSubject<String, Never>()
    }
    
    struct Config {
        let data: StoreAccountNumberSectionResponse
    }
}

final class StoreDetailAccountNumberCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(data: config.data)
        super.init()
    }
    
    override func bind() {
        input.didTapCopyAccountNumber
            .sink { [weak self] _ in
                self?.copyAccount()
                self?.output.showToast.send(Strings.BossStoreDetail.Info.copyToast)
            }
            .store(in: &cancellables)
    }
    
    private func copyAccount() {
        let bank = output.data.bank.text
        let accountNumber = output.data.accountNumber?.text ?? ""
        let accountHolder = output.data.accountHolder?.text ?? ""
        UIPasteboard.general.string = "\(bank) \(accountHolder) \(accountHolder)"
        
        output.showToast.send(Strings.BossStoreDetail.Info.copyToast)
    }
}

extension StoreDetailAccountNumberCellViewModel: Hashable {
    static func == (lhs: StoreDetailAccountNumberCellViewModel, rhs: StoreDetailAccountNumberCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
    }
}
