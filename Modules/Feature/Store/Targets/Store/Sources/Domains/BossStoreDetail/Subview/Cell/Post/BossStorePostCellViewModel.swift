import UIKit
import Combine

import Common
import Model
import Log

final class BossStorePostCellViewModel: BaseViewModel {
    struct Input {
        let didTapContent = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let storeName: String
        let categoryIconUrl: String?
        let totalCount: Int
        let content: String
        let imageUrls: [String]
        let timeStamp: String
        let isExpanded = CurrentValueSubject<Bool, Never>(false)
    }

    let input = Input()
    let output: Output
    let data: BossStoreDetailRecentPost
    
    private let logManager: LogManagerProtocol
    
    init(data: BossStoreDetailRecentPost, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(
            storeName: data.storeName,
            categoryIconUrl: data.categoryIconUrl,
            totalCount: data.totalCount,
            content: data.post.body,
            imageUrls: data.post.sections.map { $0.url },
            timeStamp: data.post.updatedAt.toDate()?.toRelativeString() ?? data.post.updatedAt
        )
        self.data = data
        self.logManager = logManager
        
        super.init()
    }

    override func bind() {
        super.bind()
                
        input.didTapContent
            .sink { [weak self] _ in
                guard let self else { return }
                
                let value = output.isExpanded.value
                output.isExpanded.send(!value)
            }
            .store(in: &cancellables)
    }
}

extension BossStorePostCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStorePostCellViewModel: Hashable {
    static func == (lhs: BossStorePostCellViewModel, rhs: BossStorePostCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Log
private extension BossStorePostCellViewModel {
    
}
