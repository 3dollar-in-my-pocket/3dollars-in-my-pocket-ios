import Foundation
import Combine

import Networking
import Model
import Common

extension BossStorePostListViewModel {
    struct Input {
        let loadTrigger = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapPhoto = PassthroughSubject<(postIndex: Int, photoIndex: Int), Never>()
        let didTapLike = PassthroughSubject<Int, Never>()
    }

    struct Output {
        let showLoading = PassthroughSubject<Bool, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let sectionItems = CurrentValueSubject<[BossStorePostListCellViewModel], Never>([])
        let route = PassthroughSubject<Route, Never>()
    }
    
    enum Route {
        case showErrorAlert(Error)
        case presentPhotoDetail(BossStorePhotoViewModel)
    }
    
    struct State {
        var nextCursor: String? = nil
        var hasMore: Bool = true
        var posts: [PostWithStoreResponse] = []
    }
    
    public struct Config {
        let storeId: String
        
        public init(storeId: String) {
            self.storeId = storeId
        }
    }
    
    public struct Dependency {
        let storeRepository: StoreRepository
        let preference: Preference
        
        public init(
            storeRepository: StoreRepository = StoreRepositoryImpl(),
            preference: Preference = .shared
        ) {
            self.storeRepository = storeRepository
            self.preference = preference
        }
    }
}

public final class BossStorePostListViewModel: BaseViewModel {
    let input = Input()
    let output = Output()

    private let config: Config
    private var state = State()
    private let dependency: Dependency
    
    public init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency
        super.init()
    }

    public override func bind() {
        super.bind()
        
        input.loadTrigger
            .withUnretained(self)
            .sink(receiveValue: { (owner: BossStorePostListViewModel, _) in
                owner.fetchPosts()
            })
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .filter { owner, row in
                owner.canLoadMore(willDisplayRow: row)
            }
            .sink { owner, _ in
                owner.fetchPosts()
            }
            .store(in: &cancellables)
        
        input.didTapPhoto
            .withUnretained(self)
            .sink { (owner: BossStorePostListViewModel, value: (postIndex: Int, photoIndex: Int)) in
                let (postIndex, photoIndex) = value
                owner.presentPhotoDetail(postIndex: postIndex, photoIndex: photoIndex)
            }
            .store(in: &cancellables)
        
        input.didTapLike
            .withUnretained(self)
            .sink { (owner: BossStorePostListViewModel, index: Int) in
                owner.toggleSticker(index: index)
            }
            .store(in: &cancellables)
    }
    
    private func fetchPosts() {
        Task {
            output.showLoading.send(true)
            let cursor = CursorRequestInput(size: 20, cursor: state.nextCursor)
            let result = await dependency.storeRepository.fetchNewPosts(storeId: config.storeId, cursor: cursor)
            
            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                state.posts.append(contentsOf: response.contents)
                updatePosts()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
            output.showLoading.send(false)
        }
    }
    
    private func updatePosts() {
        let cellViewModels = state.posts.enumerated().map { (index, data) in
            bindPostCellViewModel(data: data, index: index)
        }
        
        output.sectionItems.send(cellViewModels)
    }
    
    private func canLoadMore(willDisplayRow: Int) -> Bool {
        return willDisplayRow == state.posts.count - 1 && state.hasMore
    }
    
    private func bindPostCellViewModel(data: PostWithStoreResponse, index: Int) -> BossStorePostListCellViewModel {
        let config = BossStorePostListCellViewModel.Config(data: data, index: index)
        let cellViewModel = BossStorePostListCellViewModel(config: config)
        
        cellViewModel.output.didTapPhoto
            .subscribe(input.didTapPhoto)
            .store(in: &cellViewModel.cancellables)
        
        cellViewModel.output.didTapLike
            .subscribe(input.didTapLike)
            .store(in: &cellViewModel.cancellables)
        return cellViewModel
    }
    
    private func presentPhotoDetail(postIndex: Int, photoIndex: Int) {
        guard let post = state.posts[safe: postIndex] else { return }
        
        let photos = post.sections.map { ImageResponse(imageUrl: $0.url) }
        let config = BossStorePhotoViewModel.Config(photos: photos, selectedIndex: photoIndex)
        let viewModel = BossStorePhotoViewModel(config: config)
        
        output.route.send(.presentPhotoDetail(viewModel))
    }
    
    private func toggleSticker(index: Int) {
        Task { [weak self] in
            guard let self,
                  let post = state.posts[safe: index],
                  var sticker = post.stickers.first else { return }
            
            let targetSticker = StoreNewsPostStickerRequest(stickerId: sticker.stickerId)
            let input = StoreNewsPostStickersReplaceRequest(stickers: [targetSticker])
            let result = await dependency.storeRepository.togglePostSticker(
                storeId: config.storeId,
                postId: post.postId,
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
                
                state.posts[index].stickers[0] = sticker
                updatePosts()
            case .failure(let error):
                output.route.send(.showErrorAlert(error))
            }
        }
    }
}
