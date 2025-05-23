import Foundation
import Combine

import Common
import Model

extension HomeStoreCardCellViewModel {
    struct Input {
        let didTapActionButton = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let data: HomeCardSectionResponse
        let didTapActionButton = PassthroughSubject<SDLink, Never>()
    }
    
    struct Config {
        let data: HomeCardSectionResponse
    }
}

final class HomeStoreCardCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    lazy var identifier = ObjectIdentifier(self)
    
    init(config: Config) {
        self.output = Output(data: config.data)
    }
    
    override func bind() {
        input.didTapActionButton
            .sink(receiveValue: { [weak self] _ in
                guard let link = self?.output.data.link else { return }
                
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
