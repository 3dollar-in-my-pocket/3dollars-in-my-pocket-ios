import UIKit
import Photos

import RxSwift
import RxCocoa
import ReactorKit

final class RegisterPhotoReactor: BaseReactor, Reactor {
    enum Action {
        case viewDidLoad
        case selectPhoto(row: Int)
        case deSelectPhoto(row: Int)
        case tapRegister
    }
    
    enum Mutation {
        case setPhotos([PHAsset])
        case selectPhoto(PHAsset)
        case showLoading(isShow: Bool)
        case showErrorAlert(error: Error)
    }
    
    struct State {
        var selectedPhotos: [PHAsset]
        var photos: [PHAsset]
    }
    
    let initialState: State
    let storeService: StoreServiceProtocol
    let dismissPublisher = PublishRelay<Void>()
    private let storeId: Int
    private let globalState: GlobalState
//    var assets: PHFetchResult<PHAsset>!
//    var selectedIndex: [Int] = []
//    var selectedPhoto: [UIImage] = []
    
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
        globalState: GlobalState,
        state: State = State(selectedPhotos: [], photos: [])
    ) {
        self.storeId = storeId
        self.storeService = storeService
        self.globalState = globalState
        self.initialState = state
        super.init()
        
//        self.input.selectPhoto
//            .bind(onNext: self.selectPhoto)
//            .disposed(by: disposeBag)
//
//        self.input.tapRegisterButton
//            .map { (self.storeId, self.selectedPhoto) }
//            .bind(onNext: self.savePhotos)
//            .disposed(by: disposeBag)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return self.requestPhotosPermission()
            
        case .selectPhoto(let row):
            
        case .deSelectPhoto(let row):
        case .tapRegister:
        }
    }
    
    private func requestPhotosPermission() -> Observable<Mutation> {
        let photoAuthorizationStatusStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatusStatus {
        case .authorized:
            return self.fetchPhotos()
            
        case .denied:
            return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    return self.fetchPhotos()
                    
                case .denied:
                    return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
                    
                default:
                    return .empty()
                }
            }
        case .restricted:
            return .just(.showErrorAlert(error: BaseError.custom("사진 제보를 위해 앨범 권한이 필요합니다.")))
            
        default:
            return .empty()
        }
    }
    
    private func fetchPhotos() -> Observable<Mutation> {
        let fetchOption = PHFetchOptions().then {
            $0.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        }
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOption)
        let photos = fetchResult.objects(at: IndexSet(0..<fetchResult.count - 1))
        
        return .just(.setPhotos(photos))
    }
    
    private func selectPhoto(selectedIndex: Int, image: UIImage) {
        if self.selectedIndex.contains(selectedIndex) {
            if let index = self.selectedIndex.firstIndex(of: selectedIndex) {
                self.selectedPhoto.remove(at: index)
                self.selectedIndex.remove(at: index)
            }
        } else {
            if self.selectedIndex.count != 3 {
                self.selectedIndex.append(selectedIndex)
                self.selectedPhoto.append(image)
            } else {
                self.output.deSelectPublisher.accept(selectedIndex)
            }
        }
        
        self.output.registerButtonIsEnable.accept(!self.selectedIndex.isEmpty)
        self.output.registerButtonText.accept(String(
            format: "register_photo_button_format".localized,
            self.selectedIndex.count
        ))
    }
    
    private func savePhotos(storeId: Int, photos: [UIImage]) {
        let savePhotoObservables = photos
            .map { self.storeService.savePhoto(storeId: storeId, photos: [$0])}
        
        self.output.showLoading.accept(true)
        Observable.zip(savePhotoObservables)
            .subscribe(
                onNext: { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.output.dismiss.accept(())
                    self.output.showLoading.accept(false)
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    if let httpError = error as? HTTPError {
                        self.httpErrorAlert.accept(httpError)
                    }
                    if let commonError = error as? CommonError {
                        let alertContent = AlertContent(
                            title: nil,
                            message: commonError.description
                        )
                        
                        self.showSystemAlert.accept(alertContent)
                    }
                    self.output.showLoading.accept(false)
                }
            )
            .disposed(by: disposeBag)
    }
}
