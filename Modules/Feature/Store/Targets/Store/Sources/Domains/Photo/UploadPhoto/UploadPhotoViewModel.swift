import UIKit
import Combine
import Photos

import Common
import Networking
import AppInterface
import DependencyInjection

final class UploadPhotoViewModel: BaseViewModel {
    enum Constant {
        static let limitOfPhoto = 3
    }
    
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let selectAsset = PassthroughSubject<Int, Never>()
        let deSelectAsset = PassthroughSubject<Int, Never>()
        let didTapUpload = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let assets = PassthroughSubject<[PHAsset], Never>()
        let onSuccessUploadPhotos = PassthroughSubject<[PHAsset], Never>()
        let uploadButtonTitle = CurrentValueSubject<Int, Never>(0)
        let isEnableUploadButton = CurrentValueSubject<Bool, Never>(false)
        let showErrorAlert = PassthroughSubject<Error, Never>()
        let showToast = PassthroughSubject<String, Never>()
        let showLoading = PassthroughSubject<Bool, Never>()
        let route = PassthroughSubject<Route, Never>()
    }
    
    struct State {
        var selectedAssets: [PHAsset] = []
        var assets: [PHAsset] = []
    }
    
    enum Route {
        case dismiss
    }
    
    struct Config {
        let storeId: Int
    }
    
    let input = Input()
    let output = Output()
    var state = State()
    private let config: Config
    private let storeService: StoreServiceProtocol
    private let photoManager: PhotoManagerProtocol
    
    init(
        config: Config,
        storeService: StoreServiceProtocol = StoreService()
    ) {
        self.config = config
        self.storeService = storeService
        
        guard let appModuleInterface = DIContainer.shared.container.resolve(AppModuleInterface.self) else {
            fatalError("⚠️ AppModuleInterface가 등록되지 않았습니다.")
        }
        
        self.photoManager = appModuleInterface.photoManager
    }
    
    override func bind() {
        input.load
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewModel, _) in
                switch owner.photoManager.getPhotoAuthorizationStatus() {
                case .authorized:
                    owner.fetchPhotos()
                    
                case .denied:
                    owner.output.showErrorAlert.send(PhotoError.notAuth)
                    
                case .notDetermined:
                    owner.requestPhotosPermission()
                    
                case .restricted:
                    owner.output.showErrorAlert.send(PhotoError.notAuth)
                    
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        input.selectAsset
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewModel, index) in
                guard let selectedAsset = owner.state.assets[safe: index] else { return }
                
                owner.state.selectedAssets.append(selectedAsset)
                owner.output.uploadButtonTitle.send(owner.state.selectedAssets.count)
                owner.output.isEnableUploadButton.send(owner.isEnableUploadButton())
            }
            .store(in: &cancellables)
        
        input.deSelectAsset
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewModel, index) in
                guard let deSelectedAsset = owner.state.assets[safe: index] else { return }
                
                if let targetIndex = owner.state.selectedAssets.firstIndex(of: deSelectedAsset) {
                    owner.state.selectedAssets.remove(at: targetIndex)
                }
                owner.output.uploadButtonTitle.send(owner.state.selectedAssets.count)
                owner.output.isEnableUploadButton.send(owner.isEnableUploadButton())
            }
            .store(in: &cancellables)
        
        input.didTapUpload
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewModel, _) in
                
            }
            .store(in: &cancellables)
    }
    
    private func requestPhotosPermission() {
        photoManager.requestPhotosPermission()
            .withUnretained(self)
            .sink { (owner: UploadPhotoViewModel, status) in
                switch status {
                case .authorized:
                    owner.fetchPhotos()
                    
                case .denied:
                    owner.output.showErrorAlert.send(PhotoError.notAuth)
                    
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchPhotos() {
        let assets = photoManager.fetchAssets()
        
        state.assets = assets
        output.assets.send(assets)
    }
    
    private func isEnableUploadButton() -> Bool {
        return state.selectedAssets.count == Constant.limitOfPhoto
    }
    
//    func mutate(action: Action) -> Observable<Mutation> {
//        switch action {
//        case .viewDidLoad:
//            switch self.photoManager.getPhotoAuthorizationStatus() {
//            case .authorized:
//                return self.fetchPhotos()
//
//            case .denied:
//                return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
//
//            case .notDetermined:
//                return self.requestPhotosPermission()
//
//            case .restricted:
//                return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
//
//            default:
//                return .empty()
//            }
//
//        case .selectAsset(let row):
//            if self.currentState.selectedAssets.count == 3 {
//                return .just(.deSelectAsset(row: row))
//
//            } else {
//                let selectedPhoto = self.currentState.assets[row]
//
//                return .just(.appendToSelectedAsset(selectedPhoto))
//            }
//
//        case .deSelectAsset(let row):
//            let deSelectedPhoto = self.currentState.assets[row]
//
//            return .just(.removeFromSelectedAsset(deSelectedPhoto))
//
//        case .tapRegister:
//            let assets = self.currentState.selectedAssets
//
//            return .concat([
//                .just(.showLoading(isShow: true)),
//                self.savePhotos(storeId: self.storeId, assets: assets),
//                .just(.showLoading(isShow: false))
//            ])
//        }
//    }
//
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//
//        switch mutation {
//        case .setAssets(let assets):
//            newState.assets = assets
//
//        case .deSelectAsset(let row):
//            self.deSelectPublisher.accept(row)
//
//        case .appendToSelectedAsset(let assets):
//            newState.selectedAssets.append(assets)
//
//        case .removeFromSelectedAsset(let assets):
//            if let targetIndex = state.selectedAssets.firstIndex(of: assets) {
//                newState.selectedAssets.remove(at: targetIndex)
//            }
//
//        case .dismiss:
//            self.dismissPublisher.accept(())
//
//        case .showLoading(let isShow):
//            self.showLoadingPublisher.accept(isShow)
//
//        case .showErrorAlert(let error):
//            self.showErrorAlertPublisher.accept(error)
//        }
//
//        return newState
//    }
//
//    private func savePhotos(storeId: Int, assets: [PHAsset]) -> Observable<Mutation> {
//        let photos = assets.map { ImageUtils.getImage(from: $0) }
//
//        return self.storeService.savePhoto(storeId: storeId, photos: photos)
//            .do { [weak self] images in
//                self?.globalState.addStorePhotos.onNext(images)
//            }
//            .map { _ in .dismiss }
//            .catch { .just(.showErrorAlert(error: $0)) }
//    }
}
