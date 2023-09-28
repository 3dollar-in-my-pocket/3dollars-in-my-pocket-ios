import Photos
import Combine

import AppInterface

import RxSwift

protocol PhotoManagerProtocol: AnyObject {
    func getPhotoAuthorizationStatus() -> PHAuthorizationStatus
    
    func requestPhotosPermission() -> Observable<PHAuthorizationStatus>
}

final class PhotoManager: PhotoManagerProtocol {
    static let shared = PhotoManager()
    
    func getPhotoAuthorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestPhotosPermission() -> Observable<PHAuthorizationStatus> {
        return .create { observer in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                observer.onNext(status)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

final class CombinePhotoManager: AppInterface.PhotoManagerProtocol {
    public static let shared = CombinePhotoManager()
    
    public func getPhotoAuthorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    public func requestPhotosPermission() -> Future<PHAuthorizationStatus, Never> {
        return .init { promise in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                promise(.success(status))
            }
        }
    }
    
    public func fetchAssets() -> [PHAsset] {
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOption)
        let assets = fetchResult.objects(at: IndexSet(0..<fetchResult.count - 1))
        return assets
    }
}
