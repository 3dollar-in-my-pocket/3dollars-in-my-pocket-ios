import Common
import Model

extension StoreDetailBaseInfoCellViewModel {
    struct Output {
        let data: BasicStoreInfoSectionResponse
    }
    
    struct Config {
        let data: BasicStoreInfoSectionResponse
    }
}

final class StoreDetailBaseInfoCellViewModel: BaseViewModel {
    let output: Output
    
    init(config: Config) {
        self.output = Output(data: config.data)
    }
}

extension StoreDetailBaseInfoCellViewModel: Hashable {
    static func == (lhs: StoreDetailBaseInfoCellViewModel, rhs: StoreDetailBaseInfoCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
    }
}
