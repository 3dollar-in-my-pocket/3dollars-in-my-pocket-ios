import ReactorKit
import RxSwift
import RxCocoa

final class PhotoDetailReactor: BaseReactor, Reactor {
    enum Action {
        case scrollMainPhoto(index: Int)
        case tapSubPhoto(index: Int)
        case deletePhoto
    }
    
    enum Mutation {
        case selectPhoto(index: Int)
        case removePhoto(index: Int)
        case showLoading(isShow: Bool)
        case showErrorAlert(Error)
    }
    
    struct State {
        var photos: [Image]
        var selectedIndex: Int
    }
    
    let initialState: State
    let dismissPublisher = PublishRelay<Void>()
    private let storeId: Int
    private let storeService: StoreServiceProtocol
    private let globalState: GlobalState
    
    init(
        storeId: Int,
        selectedIndex: Int,
        photos: [Image],
        storeService: StoreServiceProtocol,
        globalState: GlobalState
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.globalState = globalState
        self.initialState = State(photos: photos, selectedIndex: selectedIndex)
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .scrollMainPhoto(let index):
            return .just(.selectPhoto(index: index))
            
        case .tapSubPhoto(let index):
            return .just(.selectPhoto(index: index))
            
        case .deletePhoto:
            return .concat([
                .just(.showLoading(isShow: true)),
                self.deletePhoto(targetIndex: self.currentState.selectedIndex),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .selectPhoto(let index):
            newState.selectedIndex = index
            
        case .removePhoto(let index):
            newState.photos.remove(at: index)
            
            if newState.photos.isEmpty {
                self.dismissPublisher.accept(())
            } else {
                if newState.selectedIndex - 1 < 0 {
                    newState.selectedIndex = 0
                } else {
                    newState.selectedIndex -= 1
                }
            }
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func deletePhoto(targetIndex: Int) -> Observable<Mutation> {
        let targetImage = self.currentState.photos[targetIndex]
        
        return self.storeService.deletePhoto(photoId: targetImage.imageId)
            .do(onNext: { [weak self] _ in
                self?.globalState.deletedPhoto.onNext(targetImage.imageId)
            })
            .map { .removePhoto(index: targetIndex) }
            .catch { .just(.showErrorAlert($0)) }
    }
}
