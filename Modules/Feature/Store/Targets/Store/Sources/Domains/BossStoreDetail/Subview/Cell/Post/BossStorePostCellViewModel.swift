import UIKit
import Combine

import Common
import Model
import Networking

extension BossStorePostCellViewModel {
    struct Input {
        let didTapMore = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didTapContent = PassthroughSubject<Void, Never>()
        let didScroll = PassthroughSubject<CGPoint, Never>()
        let didTapLike = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let store: BossStoreResponse
        var post: PostResponse
        let totalCount: Int
        let didTapMore = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let scrollOffset = CurrentValueSubject<CGPoint, Never>(.zero)
        let expendContent = CurrentValueSubject<Bool, Never>(false)
        let sticker: CurrentValueSubject<StickerResponse?, Never>
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct Config {
        let store: BossStoreResponse
        let post: PostResponse
        let totalCount: Int
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        
        init(storeRepository: StoreRepository = StoreRepositoryImpl()) {
            self.storeRepository = storeRepository
        }
    }
}

final class BossStorePostCellViewModel: BaseViewModel {
    let input = Input()
    var output: Output
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(
            store: config.store,
            post: config.post,
            totalCount: config.totalCount,
            sticker: .init(config.post.stickers.first)
        )
        self.dependency = dependency
        super.init()
    }
    
    override func bind() {
        input.didTapMore
            .subscribe(output.didTapMore)
            .store(in: &cancellables)
        
        input.didTapPhoto
            .subscribe(output.didTapPhoto)
            .store(in: &cancellables)
        
        input.didTapContent
            .withUnretained(self)
            .sink { (owner: BossStorePostCellViewModel, _) in
                owner.output.expendContent.send(true)
            }
            .store(in: &cancellables)
        
        input.didScroll
            .subscribe(output.scrollOffset)
            .store(in: &cancellables)
        
        input.didTapLike
            .withUnretained(self)
            .sink { (owner: BossStorePostCellViewModel, _) in
                owner.toggleSticker()
            }
            .store(in: &cancellables)
    }
    
    private func toggleSticker() {
        Task {
            guard var sticker = output.post.stickers.first else { return }
            
            let targetSticker = StoreNewsPostStickerRequest(stickerId: sticker.stickerId)
            let input = StoreNewsPostStickersReplaceRequest(stickers: [targetSticker])
            let result = await dependency.storeRepository.togglePostSticker(
                storeId: output.store.storeId,
                postId: output.post.postId,
                input: input
            )
            
            switch result {
            case .success(_):
                sticker.reactedByMe.toggle()
                
                if sticker.reactedByMe {
                    sticker.count += 1
                } else {
                    sticker.count -= 1
                }
                
                output.post.stickers[0] = sticker
                output.sticker.send(sticker)
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
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
