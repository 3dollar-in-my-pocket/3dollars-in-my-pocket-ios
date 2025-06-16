import UIKit
import Combine

import Common
import Model
import Networking

extension StoreDetailNewsCellViewModel {
    struct Input {
        let didTapMore = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didTapContent = PassthroughSubject<Void, Never>()
        let didScroll = PassthroughSubject<CGPoint, Never>()
        let didTapLike = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let header: HeaderSectionResponse
        let news: StoreNewsSectionResponse.StoreNewsCardSectionResponse?
        let moreButton: SDText?
        let didTapMore = PassthroughSubject<Void, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let scrollOffset = CurrentValueSubject<CGPoint, Never>(.zero)
        let expendContent = CurrentValueSubject<Bool, Never>(false)
        let sticker: CurrentValueSubject<StoreNewsSectionResponse.StoreNewsCardSectionResponse.LikeSectionResponse?, Never>
        let showErrorAlert = PassthroughSubject<Error, Never>()
    }
    
    struct Config {
        let data: StoreNewsSectionResponse
    }
    
    struct Dependency {
        let storeRepository: StoreRepository
        
        init(storeRepository: StoreRepository = StoreRepositoryImpl()) {
            self.storeRepository = storeRepository
        }
    }
}

final class StoreDetailNewsCellViewModel: BaseViewModel {
    let input = Input()
    var output: Output
    private let dependency: Dependency
    
    init(config: Config, dependency: Dependency = Dependency()) {
        self.output = Output(
            header: config.data.header,
            news: config.data.cards.first,
            moreButton: config.data.moreButton,
            sticker: .init(config.data.cards.first?.likeButton)
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
            .sink { [weak self] _ in
                self?.output.expendContent.send(true)
            }
            .store(in: &cancellables)
        
        input.didScroll
            .subscribe(output.scrollOffset)
            .store(in: &cancellables)
        
        input.didTapLike
            .sink { [weak self] _ in
                self?.toggleSticker()
            }
            .store(in: &cancellables)
    }
    
    private func toggleSticker() {
        Task {
            // TODO: 변경된 서버값에 stickerId 없어서 변경 후 적용 필요!
//            guard var sticker = output.post.stickers.first else { return }
//            
//            let targetSticker = StoreNewsPostStickerRequest(stickerId: sticker.stickerId)
//            let input = StoreNewsPostStickersReplaceRequest(stickers: [targetSticker])
//            let result = await dependency.storeRepository.togglePostSticker(
//                storeId: output.store.storeId,
//                postId: output.post.postId,
//                input: input
//            )
//            
//            switch result {
//            case .success(_):
//                sticker.reactedByMe.toggle()
//                
//                if sticker.reactedByMe {
//                    sticker.count += 1
//                } else {
//                    sticker.count -= 1
//                }
//                
//                output.post.stickers[0] = sticker
//                output.sticker.send(sticker)
//            case .failure(let error):
//                output.showErrorAlert.send(error)
//            }
        }
    }
}

extension StoreDetailNewsCellViewModel: Hashable {
    static func == (lhs: StoreDetailNewsCellViewModel, rhs: StoreDetailNewsCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(output.header)
        hasher.combine(output.moreButton)
        hasher.combine(output.news)
    }
}
