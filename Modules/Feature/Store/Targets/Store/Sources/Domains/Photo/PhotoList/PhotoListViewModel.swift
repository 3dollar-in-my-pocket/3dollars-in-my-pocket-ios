import Foundation
import Combine

import Common
import Networking
import Model

final class PhotoListViewModel: BaseViewModel {
    struct Input {
        let viewDidLoad = PassthroughSubject<Void, Never>()
        let willDisplayCell = PassthroughSubject<Int, Never>()
        let didTapPhoto = PassthroughSubject<Int, Never>()
        let didTapUpload = PassthroughSubject<Void, Never>()
        let onSuccessUploadPhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
        
        /// 사진 상세화면에서 업데이트된 State이벤트 받음
        let updateState = PassthroughSubject<State, Never>()
    }
    
    struct Output {
        let photos = PassthroughSubject<[StoreDetailPhoto], Never>()
        let route = PassthroughSubject<Route, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let onSuccessUploadPhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
    }
    
    struct State {
        var photos: [StoreDetailPhoto] = []
        var nextCursor: String?
        var hasMore = true
    }
    
    enum Route {
        case presentPhotoDetail(PhotoDetailViewModel)
        case presentUploadPhoto(UploadPhotoViewModel)
    }
    
    struct Config {
        let storeId: Int
    }
    
    let input = Input()
    let output = Output()
    private let storeRepository: StoreRepository
    private let config: Config
    private var state = State()
    
    init(config: Config, storeRepository: StoreRepository = StoreRepositoryImpl()) {
        self.config = config
        self.storeRepository = storeRepository
    }
    
    override func bind() {
        input.viewDidLoad
            .withUnretained(self)
            .sink { (owner: PhotoListViewModel, _) in
                owner.fetchStorePhotos()
            }
            .store(in: &cancellables)
        
        input.willDisplayCell
            .withUnretained(self)
            .filter { (owner: PhotoListViewModel, index: Int) in
                return owner.canLoadMore(index: index)
            }
            .sink { (owner: PhotoListViewModel, _) in
                owner.fetchMoreStorePhotos(cursor: owner.state.nextCursor)
            }
            .store(in: &cancellables)
        
        input.didTapPhoto
            .withUnretained(self)
            .sink { (owner: PhotoListViewModel, index: Int) in
                owner.presentPhotoDetail(index: index)
            }
            .store(in: &cancellables)
        
        input.didTapUpload
            .withUnretained(self)
            .sink { (owner: PhotoListViewModel, _) in
                owner.presentUploadPhoto()
            }
            .store(in: &cancellables)
        
        input.onSuccessUploadPhotos
            .withUnretained(self)
            .sink { (owner: PhotoListViewModel, photos: [StoreDetailPhoto]) in
                owner.state.photos.insert(contentsOf: photos, at: 0)
//                owner.state.photos.append(contentsOf: photos)
                owner.output.photos.send(owner.state.photos)
            }
            .store(in: &cancellables)
        
        input.onSuccessUploadPhotos
            .subscribe(output.onSuccessUploadPhotos)
            .store(in: &cancellables)
        
        input.updateState
            .withUnretained(self)
            .sink { (owner: PhotoListViewModel, state: State) in
                owner.state = state
                owner.output.photos.send(owner.state.photos)
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
                state.photos.append(contentsOf: response.contents.map { StoreDetailPhoto(response: $0.image) })
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
                
            case .failure(let error):
                output.showErrorAlert.send(error)
            }
        }
    }
    
    private func canLoadMore(index: Int) -> Bool {
        return index >= state.photos.count - 1 && state.hasMore
    }
    
    private func presentUploadPhoto() {
        let config = UploadPhotoViewModel.Config(uploadType: .storeImage(storeId: config.storeId))
        let viewModel = UploadPhotoViewModel(config: config)
        
        viewModel.output.onSuccessUploadPhotos
            .subscribe(input.onSuccessUploadPhotos)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentUploadPhoto(viewModel))
    }
    
    private func presentPhotoDetail(index: Int) {
        let config = PhotoDetailViewModel.Config(
            storeId: config.storeId,
            photos: state.photos,
            nextCursor: state.nextCursor,
            hasMore: state.hasMore,
            currentIndex: index
        )
        let viewModel = PhotoDetailViewModel(config: config)
        
        viewModel.output.updatePhotoListState
            .subscribe(input.updateState)
            .store(in: &viewModel.cancellables)
        
        output.route.send(.presentPhotoDetail(viewModel))
    }
}
