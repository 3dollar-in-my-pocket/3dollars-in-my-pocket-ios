import Photos
import Combine

public protocol PhotoManagerProtocol: AnyObject {
    func getPhotoAuthorizationStatus() -> PHAuthorizationStatus
    
    func requestPhotosPermission() -> Future<PHAuthorizationStatus, Never>
    
    func fetchAssets() -> [PHAsset]
}
