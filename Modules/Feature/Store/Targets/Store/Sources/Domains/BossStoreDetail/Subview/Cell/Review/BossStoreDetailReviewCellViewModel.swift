import Combine

import Common
import Model

final class BossStoreDetailReviewCellViewModel: BaseViewModel {
    struct Input {
    }
    
    struct Output {
        let review: StoreDetailReview
    }
    
    let input = Input()
    let output: Output
    
    init(data: StoreDetailReview) {
        self.output = Output(review: data)
        
        super.init()
    }
    
    override func bind() {
        super.bind()
        
    }
}

extension BossStoreDetailReviewCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStoreDetailReviewCellViewModel: Hashable {
    static func == (lhs: BossStoreDetailReviewCellViewModel, rhs: BossStoreDetailReviewCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
