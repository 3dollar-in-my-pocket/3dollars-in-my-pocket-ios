import UIKit
import Photos

import RxSwift
import RxCocoa
import ReactorKit

final class RegisterPhotoReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case selectAsset(row: Int)
        case deSelectAsset(row: Int)
        case tapRegister
    }
    
    enum Mutation {
        case setAssets([PHAsset])
        case deSelectAsset(row: Int)
        case appendToSelectedAsset(PHAsset)
        case removeFromSelectedAsset(PHAsset)
        case dismiss
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var selectedAssets: [PHAsset]
        var assets: [PHAsset]
    }
    
    let initialState: State
    let dismissPublisher = PublishRelay<Void>()
    let deSelectPublisher = PublishRelay<Int>()
    private let storeId: Int
    private let storeService: StoreServiceProtocol
    private let photoManager: PhotoManagerProtocol
    private let globalState: GlobalState
    
    struct Output {
        let registerButtonIsEnable = PublishRelay<Bool>()
        let registerButtonText = PublishRelay<String>()
        let deSelectPublisher = PublishRelay<Int>()
        let photos = PublishRelay<[PHAsset]>()
        let dismiss = PublishRelay<Void>()
        let showLoading = PublishRelay<Bool>()
    }
    
    init(
        storeId: Int,
        storeService: StoreServiceProtocol,
        photoManager: PhotoManagerProtocol,
        globalState: GlobalState,
        state: State = State(selectedAssets: [], assets: [])
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.photoManager = photoManager
        self.globalState = globalState
        self.initialState = state
        
        super.init()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            switch self.photoManager.getPhotoAuthorizationStatus() {
            case .authorized:
                return self.fetchPhotos()
                
            case .denied:
                return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
                
            case .notDetermined:
                return self.requestPhotosPermission()
                
            case .restricted:
                return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
                
            default:
                return .empty()
            }
            
        case .selectAsset(let row):
            if self.currentState.selectedAssets.count == 3 {
                return .just(.deSelectAsset(row: row))
                
            } else {
                let selectedPhoto = self.currentState.assets[row]
                
                return .just(.appendToSelectedAsset(selectedPhoto))
            }
            
        case .deSelectAsset(let row):
            let deSelectedPhoto = self.currentState.assets[row]
            
            return .just(.removeFromSelectedAsset(deSelectedPhoto))
            
        case .tapRegister:
            let assets = self.currentState.selectedAssets
            
            return .concat([
                .just(.showLoading(isShow: true)),
                self.savePhotos(storeId: self.storeId, assets: assets),
                .just(.showLoading(isShow: false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setAssets(let assets):
            newState.assets = assets
            
        case .deSelectAsset(let row):
            self.deSelectPublisher.accept(row)
            
        case .appendToSelectedAsset(let assets):
            newState.selectedAssets.append(assets)
            
        case .removeFromSelectedAsset(let assets):
            if let targetIndex = state.selectedAssets.firstIndex(of: assets) {
                newState.selectedAssets.remove(at: targetIndex)
            }
            
        case .dismiss:
            self.dismissPublisher.accept(())
            
        case .showLoading(let isShow):
            self.showLoadingPublisher.accept(isShow)
            
        case .showErrorAlert(let error):
            self.showErrorAlertPublisher.accept(error)
        }
        
        return newState
    }
    
    private func requestPhotosPermission() -> Observable<Mutation> {
        return self.photoManager.requestPhotosPermission()
            .flatMap { [weak self] authorizationStatus -> Observable<Mutation> in
                guard let self = self else { return .error(BaseError.unknown) }
                
                switch authorizationStatus {
                case .authorized:
                    return self.fetchPhotos()
                    
                case .denied:
                    return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
                    
                default:
                    return .empty()
                }
            }
    }
    
    private func fetchPhotos() -> Observable<Mutation> {
        let fetchOption = PHFetchOptions().then {
            $0.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOption)
        let assets = fetchResult.objects(at: IndexSet(0..<fetchResult.count - 1))
        
        return .just(.setAssets(assets))
    }
    
    private func savePhotos(storeId: Int, assets: [PHAsset]) -> Observable<Mutation> {
        let photos = assets.map { ImageUtils.getImage(from: $0) }
        
        return self.storeService.savePhoto(storeId: storeId, photos: photos)
            .do { [weak self] images in
                self?.globalState.addStorePhotos.onNext(images)
            }
            .map { _ in .dismiss }
            .catch { .just(.showErrorAlert(error: $0)) }
    }
}
