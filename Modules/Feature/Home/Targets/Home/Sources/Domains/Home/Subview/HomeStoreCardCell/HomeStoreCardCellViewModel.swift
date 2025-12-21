import Foundation
import Combine

import Common
import Model
import Log

extension HomeStoreCardCellViewModel {
    struct Input {
        let didTapActionButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screen: ScreenName = .home
        let data: HomeCardSectionResponse
        let didTapActionButton = PassthroughSubject<SDLink, Never>()
    }
    
    struct Config {
        let data: HomeCardSectionResponse
    }
    
    struct Dependency {
        let logManager: LogManagerProtocol
        
        init(logManager: LogManagerProtocol = LogManager.shared) {
            self.logManager = logManager
        }
    }
}

final class HomeStoreCardCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    lazy var identifier = ObjectIdentifier(self)
    
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(data: config.data)
        self.dependency = dependency
    }
    
    override func bind() {
        input.didTapActionButton
            .sink(receiveValue: { [weak self] _ in
                guard let link = self?.output.data.button?.link else { return }
                
                self?.sendClickActionButtonLog()
                self?.output.didTapActionButton.send(link)
            })
            .store(in: &cancellables)
    }
}

extension HomeStoreCardCellViewModel: Hashable, Identifiable, Equatable {
    static func == (lhs: HomeStoreCardCellViewModel, rhs: HomeStoreCardCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: Log
extension HomeStoreCardCellViewModel {
    private func sendClickActionButtonLog() {
        dependency.logManager.sendEvent(event: ClickEvent(
            screen: output.screen,
            objectType: .button,
            objectId: .visit
        ))
    }
}
