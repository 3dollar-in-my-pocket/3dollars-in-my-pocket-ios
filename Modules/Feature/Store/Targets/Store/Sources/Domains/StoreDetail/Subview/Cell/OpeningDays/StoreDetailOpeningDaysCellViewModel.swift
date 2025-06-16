import Common
import Model

extension StoreDetailOpeningDaysCellViewModel {
    struct Output {
        let title: SDText
        let openingDays: [StoreOpeningDaysSectionResponse.StoreOpeningDaySectionResponse]
    }
    
    struct Config {
        let data: StoreOpeningDaysSectionResponse
    }
}

final class StoreDetailOpeningDaysCellViewModel: BaseViewModel {
    let output: Output
    
    init(config: Config) {
        self.output = Output(
            title: config.data.title,
            openingDays: config.data.openingDays
        )
        
        super.init()
    }
}

extension StoreDetailOpeningDaysCellViewModel: Hashable {
    static func == (lhs: StoreDetailOpeningDaysCellViewModel, rhs: StoreDetailOpeningDaysCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(output.title)
        hasher.combine(output.openingDays)
    }
}
