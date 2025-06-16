import Common
import Model

final class StoreDetailOverviewCellViewModel: BaseViewModel {
    struct Output {
        let data: StoreOverviewSectionResponse
    }
    
    struct Config {
        let data: StoreOverviewSectionResponse
    }
    
    let output: Output
    
    init(config: Config) {
        self.output = Output(data: config.data)

        super.init()
    }
}

extension StoreDetailOverviewCellViewModel: Hashable {
    static func == (lhs: StoreDetailOverviewCellViewModel, rhs: StoreDetailOverviewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.data)
    }
}
