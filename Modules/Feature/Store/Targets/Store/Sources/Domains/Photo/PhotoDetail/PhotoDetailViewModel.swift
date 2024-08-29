import Foundation
import Combine

import Common
import Model
import Networking

final class PhotoDetailViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let onCollectionViewLoad = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapLeft = PassthroughSubject<Void, Never>()
        let didTapRight = PassthroughSubject<Void, Never>()
        let deletePhoto = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let photos: CurrentValueSubject<[StoreDetailPhoto], Never>
        let scrollToIndex = PassthroughSubject<(index: Int, animated: Bool), Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        
        /// 상세화면에서 업데이트된 페이징 정보를 리스트 화면으로 전달
        let updatePhotoListState = PassthroughSubject<PhotoListViewModel.State, Never>()
    }
    
    struct State {
        var photos: [StoreDetailPhoto]
        var nextCursor: String?
        var hasMore: Bool
        var currentIndex: Int
    }
    
    struct Config {
        let storeId: Int
        var photos: [StoreDetailPhoto] = []
        var nextCursor: String?
        var hasMore: Bool
        var currentIndex: Int
    }
    
    let input = Input()
    let output: Output
    let config: Config
    private let storeRepository: StoreRepository
    private var state: State
    
    init(config: Config, storeRepository: StoreRepository = StoreRepositoryImpl()) {
        self.output = Output(photos: .init(config.photos))
        self.config = config
        self.storeRepository = storeRepository
        self.state = State(
            photos: config.photos,
            nextCursor: config.nextCursor,
            hasMore: config.hasMore,
            currentIndex: config.currentIndex
        )
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                owner.fetchStorePhotos()
            }
            .store(in: &cancellables)
        
        input.onCollectionViewLoad
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                owner.output.scrollToIndex.send((index: owner.state.currentIndex, animated: false))
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .filter { (owner: PhotoDetailViewModel, index: Int) in
                return owner.canLoadMore(index: index)
            }
            .sink { (owner: PhotoDetailViewModel, _) in
                owner.fetchMoreStorePhotos(cursor: owner.state.nextCursor)
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .dropFirst()
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, index: Int) in
                owner.state.currentIndex = index
            }
            .store(in: &cancellables)
        
        input.didTapLeft
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                guard owner.state.currentIndex - 1 >= 0 else { return }
                owner.state.currentIndex -= 1
                owner.output.scrollToIndex.send((index: owner.state.currentIndex, animated: true))
            }
            .store(in: &cancellables)
        
        input.didTapRight
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                guard owner.state.currentIndex + 1 < owner.state.photos.count else { return }
                owner.state.currentIndex += 1
                owner.output.scrollToIndex.send((index: owner.state.currentIndex, animated: true))
            }
            .store(in: &cancellables)
        
        input.deletePhoto
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewModel, _) in
                owner.deletePhoto()
            }
            .store(in: &cancellables)
    }
    
    private func fetchStorePhotos(cursor: String? = nil) {
        guard state.hasMore else { return }
        
        output.showLoading.send(true)
        Task { [weak self] in
            guard let self else { return }
            
            let result = await storeRepository.fetchStorePhotos(storeId: config.storeId, cursor: state.nextCursor)
            
            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                
                let photos = response.contents.map { StoreDetailPhoto(response: $0.image) }
                if cursor != nil {
                    state.photos = photos
                } else {
                    state.photos.append(contentsOf: photos)
                }
                 
                output.photos.send(state.photos)
                output.showLoading.send(false)
                
            case .failure(let error):
                output.showErrorAlert.send(error)
                output.showLoading.send(false)
            }
        }
    }
    
    private func fetchMoreStorePhotos(cursor: String?) {
        Task { [weak self] in
            guard let self else { return }
            
            let result = await storeRepository.fetchStorePhotos(storeId: config.storeId, cursor: state.nextCursor)
            
            switch result {
            case .success(let response):
                state.hasMore = response.cursor.hasMore
                state.nextCursor = response.cursor.nextCursor
                state.photos.append(contentsOf: response.contents.map { StoreDetailPhoto(response: $0.image) })
                output.photos.send(state.photos)
                updatePhotoListState()
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return index >= state.photos.count - 1 && state.hasMore
    }
    
    private func updatePhotoListState() {
        let updatedState = PhotoListViewModel.State(
            photos: state.photos,
            nextCursor: state.nextCursor,
            hasMore: state.hasMore
        )
        
        output.updatePhotoListState.send(updatedState)
    }
    
    private func deletePhoto() {
        guard let photoId = state.photos[safe: state.currentIndex]?.imageId else { return }
        output.showLoading.send(true)
        Task {
            let result = await storeRepository.deletePhoto(photoId: photoId)
            
            output.showLoading.send(false)
            
            switch result {
            case .success(_):
                state.photos.remove(at: state.currentIndex)
                if state.photos.count == state.currentIndex {
                    state.currentIndex -= 1
                }
                output.photos.send(state.photos)
                output.scrollToIndex.send((state.currentIndex , true))
                updatePhotoListState()
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
}
