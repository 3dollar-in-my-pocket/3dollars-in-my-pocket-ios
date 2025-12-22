import Foundation
import Combine
import Log
import Common

extension BossAppBottomSheetViewModel {
    struct Input {
        let didTapInstall = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .writeAddressBossBottomSheet
        let openUrl = PassthroughSubject<String, Never>()
    }
    
    struct Dependency {
        let logManager: LogManager
        
        init(logManager: LogManager = .shared) {
            self.logManager = logManager
        }
    }
}

final class BossAppBottomSheetViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private let dependency: Dependency
    
    init(dependency: Dependency = Dependency()) {
        self.dependency = dependency
        super.init()
    }
    
    override func bind() {
        input.didTapInstall
            .sink { [weak self] in
                self?.sendClickInstallButtonLog()
                let url = "https://massive-iguana-121.notion.site/3-28c7ad52990e809caba2fb2040677a2a?pvs=74"
                self?.output.openUrl.send(url)
            }
            .store(in: &cancellables)
    }
} 

// MARK: Log
extension BossAppBottomSheetViewModel {
    private func sendClickInstallButtonLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screenName,
            objectType: .button,
            objectId: .install
        ))
    }
}
