import Combine

import Common
import Model

extension StoreDetailCategorizedMenusCellViewModel {
    struct Input {
        let didTapMore = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let data: StoreCategorizedMenusSectionResponse
        let isShowAll: Bool
        let didTapMore = PassthroughSubject<Void, Never>()
    }
    
    struct Config {
        let data: StoreCategorizedMenusSectionResponse
        let isShowAll: Bool
    }
}


final class StoreDetailCategorizedMenusCellViewModel: BaseViewModel {
    let input = Input()
    let output: Output
    
    init(config: Config) {
        self.output = Output(data: config.data, isShowAll: config.isShowAll)
        
        super.init()
    }
    
    override func bind() {
        input.didTapMore
            .subscribe(output.didTapMore)
            .store(in: &cancellables)
    }
}

extension StoreDetailCategorizedMenusCellViewModel: Hashable {
    static func == (lhs: StoreDetailCategorizedMenusCellViewModel, rhs: StoreDetailCategorizedMenusCellViewModel) -> Bool {
        return lhs.output.data == rhs.output.data && lhs.output.isShowAll == rhs.output.isShowAll
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
        hasher.combine(output.isShowAll)
    }
}
