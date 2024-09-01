import UIKit
import Combine

import Common
import Model

final class BossStorePostListCellViewModel: BaseViewModel {
    struct Input {
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didScroll = PassthroughSubject<CGPoint, Never>()
        let didTapLike = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let didTapPhoto = PassthroughSubject<(postIndex: Int, photoIndex: Int), Never>()
        let data: PostWithStoreResponse
        let scrollOffset = CurrentValueSubject<CGPoint, Never>(.zero)
        let didTapLike = PassthroughSubject<Int, Never>()
    }
    
    struct Config {
        let data: PostWithStoreResponse
        let index: Int
    }

    let input = Input()
    let output: Output
    private let config: Config
    
    init(config: Config) {
        self.output = Output(data: config.data)
        self.config = config
        
        super.init()
    }

    override func bind() {
        super.bind()
        
        input.didScroll
            .subscribe(output.scrollOffset)
            .store(in: &cancellables)
        
        input.didTapPhoto
            .withUnretained(self)
            .sink { (owner: BossStorePostListCellViewModel, photoIndex: Int) in
                owner.output.didTapPhoto.send((owner.config.index, photoIndex))
            }
            .store(in: &cancellables)
        
        input.didTapLike
            .withUnretained(self)
            .sink { (owner: BossStorePostListCellViewModel, _) in
                owner.output.didTapLike.send(owner.config.index)
            }
            .store(in: &cancellables)
    }
}

extension BossStorePostListCellViewModel: Identifiable {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
}

extension BossStorePostListCellViewModel: Hashable {
    static func == (lhs: BossStorePostListCellViewModel, rhs: BossStorePostListCellViewModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
