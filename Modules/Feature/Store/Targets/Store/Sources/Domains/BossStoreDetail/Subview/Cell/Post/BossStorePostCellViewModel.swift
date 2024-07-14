import UIKit
import Combine

import Common
import Model
import Log

final class BossStorePostCellViewModel: BaseViewModel {
    struct Input {
        let didTapContent = PassthroughSubject<Void, Never>()
        let didTapMoreButton = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let storeName: String
        let categoryIconUrl: String?
        let totalCount: Int
        let content: String
        let imageUrls: [String]
        let timeStamp: String
        let isExpanded: CurrentValueSubject<Bool, Never>
        let moveToList = PassthroughSubject<Void, Never>()
    }
    
    struct Config {
        let data: BossStoreDetailRecentPost
        let source: Source
    }
    
    enum Source {
        case storeDetail
        case postList
    }

    let input = Input()
    let output: Output
    let config: Config
    
    private let logManager: LogManagerProtocol
    
    init(config: Config, logManager: LogManagerProtocol = LogManager.shared) {
        self.output = Output(
            storeName: config.data.storeName,
            categoryIconUrl: config.data.categoryIconUrl,
            totalCount: config.data.totalCount,
            content: config.data.post.body,
            imageUrls: config.data.post.sections.map { $0.url },
            timeStamp: config.data.post.updatedAt.toDate()?.toRelativeString() ?? config.data.post.updatedAt,
            isExpanded: .init(config.source == .storeDetail ? false : true)
        )
        self.config = config
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
        
        input.didTapMoreButton
            .subscribe(output.moveToList)
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
