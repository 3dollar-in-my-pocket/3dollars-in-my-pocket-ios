import UIKit
import Combine
import Photos

import Common
import Model
import Networking
import AppInterface
import DependencyInjection
import Log

final class UploadPhotoViewModel: BaseViewModel {
    enum UploadType {
        case storeImage(storeId: Int)
        case reviewImage(limitOfPhoto: Int)
        
        var title: String {
            switch self {
            case .storeImage: Strings.StoreDetail.Photo.Header.button
            case .reviewImage: "사진 선택"
            }
        }
        
        var limitOfPhoto: Int {
            switch self {
            case .storeImage: 3
            case .reviewImage(let limitOfPhoto): limitOfPhoto
            }
        }
    }
    
    struct Input {
        let load = PassthroughSubject<Void, Never>()
        let selectAsset = PassthroughSubject<Int, Never>()
        let deSelectAsset = PassthroughSubject<Int, Never>()
        let didTapUpload = PassthroughSubject<Void, Never>()
    }
    
    struct Output {
        let screenName: ScreenName = .uploadPhoto
        let title: String
        let limitOfPhoto: Int
        let assets = PassthroughSubject<[PHAsset], Never>()
        let onSuccessUploadPhotos = PassthroughSubject<[StoreDetailPhoto], Never>()
        let onSuccessUploadImages = PassthroughSubject<[ImageUploadResponse], Never>()
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
        let uploadType: UploadType
    }
    
    let input = Input()
    let output: Output
    var state = State()
    private let config: Config
    private let storeRepository: StoreRepository
    private let photoManager: PhotoManagerProtocol
    private let logManager: LogManagerProtocol
    private let imageUploadService: ImageUploadServiceType
    
    init(
        config: Config,
        storeRepository: StoreRepository = StoreRepositoryImpl(),
        logManager: LogManagerProtocol = LogManager.shared,
        imageUploadService: ImageUploadServiceType = ImageUploadService()
    ) {
        self.config = config
        
        self.output = Output(title: config.uploadType.title, limitOfPhoto: config.uploadType.limitOfPhoto)
        self.storeRepository = storeRepository
        self.photoManager = Environment.appModuleInterface.photoManager
        self.logManager = logManager
        self.imageUploadService = imageUploadService
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
        return state.selectedAssets.count > 0 && state.selectedAssets.count <= output.limitOfPhoto
    }
    
    private func uploadPhotos() {
        output.showLoading.send(true)
        let selectedPhotos = state.selectedAssets.map { ImageUtils.getImage(from: $0) }
        let datas = ImageUtils.dataArrayFromImages(photos: selectedPhotos)
        
        switch config.uploadType {
        case .storeImage(let storeId):
            uploadStorePhotos(storeId: storeId, datas: datas)
            sendClickUploadPhoto(count: state.selectedAssets.count, storeId: storeId)
        case .reviewImage:
            uploadImages(fileType: .storeReviewImage, datas: datas)
        }
    }
    
    private func uploadStorePhotos(storeId: Int, datas: [Data]) {
        Task { [weak self] in
            guard let self else { return }
            let result = await storeRepository.uploadPhotos(storeId: storeId, photos: datas)
            
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
    
    private func uploadImages(fileType: FileType, datas: [Data]) {
        Task { [weak self] in
            guard let self else { return }
            let result = await imageUploadService.uploadImages(datas: datas, fileType: fileType)
            
            switch result {
            case .success(let imageResponse):
                output.showLoading.send(false)
                output.onSuccessUploadImages.send(imageResponse)
                output.route.send(.dismiss)
                
            case .failure(let error):
                output.showLoading.send(false)
                output.showErrorAlert.send(error)
            }
        }
    }
}

// MARK: Log
extension UploadPhotoViewModel {
    private func sendClickUploadPhoto(count: Int, storeId: Int) {
        logManager.sendEvent(.init(
            screen: output.screenName,
            eventName: .clickUpload,
            extraParameters: [
                .storeId: storeId,
                .count: count
            ]
        ))
    }
}
