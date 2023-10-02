import UIKit
import Combine
import Photos

import Common
import Model
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
        let onSuccessUploadPhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
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
                owner.uploadPhotos()
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
        return state.selectedAssets.count > 0 && state.selectedAssets.count <= Constant.limitOfPhoto
    }
    
    private func uploadPhotos() {
        output.showLoading.send(true)
        let selectedPhotos = state.selectedAssets.map { ImageUtils.getImage(from: $0) }
        let datas = ImageUtils.dataArrayFromImages(photos: selectedPhotos)
        
        Task { [weak self] in
            guard let self else { return }
            let result = await storeService.uploadPhotos(storeId: config.storeId, photos: datas)
            
            switch result {
            case .success(let imageResponse):
                let storeDetailPhotos = imageResponse.map { StoreDetailPhoto(response: $0, totalCount: 0) }
                output.showLoading.send(false)
                output.onSuccessUploadPhotos.send(storeDetailPhotos)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.showLoading.send(false)
                output.showErrorAlert.send(error)
            }
        }
    }
}
