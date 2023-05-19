import Photos

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
