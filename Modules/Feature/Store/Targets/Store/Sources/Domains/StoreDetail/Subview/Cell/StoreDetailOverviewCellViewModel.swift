import Combine

import Common
import Model
import Networking

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
    
//    override func bind() {
//
//        input.didTapMapDetail
//            .subscribe(output.didTapMapDetail)
//            .store(in: &cancellables)
//        
    //        input.didTapAddress
    //            .subscribe(output.didTapAddress)
    //            .store(in: &cancellables)

//    }
}

extension StoreDetailOverviewCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension StoreDetailOverviewCellViewModel: Hashable {
    static func == (lhs: StoreDetailOverviewCellViewModel, rhs: StoreDetailOverviewCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
