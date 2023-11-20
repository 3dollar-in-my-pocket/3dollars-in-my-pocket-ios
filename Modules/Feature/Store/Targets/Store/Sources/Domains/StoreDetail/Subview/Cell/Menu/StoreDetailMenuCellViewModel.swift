import Combine

import Common
import Model

final class StoreDetailMenuCellViewModel: BaseViewModel {
    struct Input {
        let didTapMore = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let menus: [StoreDetailMenu]
        let isShowAll: Bool
        let didTapMore = PassthroughSubject<Void, Never>()
    }
    
    struct Config {
        let menus: [StoreDetailMenu]
        let isShowAll: Bool
    }
    
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(menus: config.menus, isShowAll: config.isShowAll)
        
        super.init()
    }
    
    override func bind() {
        input.didTapMore
            .subscribe(output.didTapMore)
            .store(in: &cancellables)
    }
}

extension StoreDetailMenuCellViewModel: Hashable {
    static func == (lhs: StoreDetailMenuCellViewModel, rhs: StoreDetailMenuCellViewModel) -> Bool {
        return lhs.output.menus == rhs.output.menus && lhs.output.isShowAll == rhs.output.isShowAll
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.menus)
        hasher.combine(output.isShowAll)
    }
}
