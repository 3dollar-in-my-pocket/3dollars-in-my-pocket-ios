import Foundation
import Photos
import Combine

import AppInterface

final class MockPhotoManager: PhotoManagerProtocol {
    func getPhotoAuthorizationStatus() -> PHAuthorizationStatus {
        return .authorized
    }
    
    func requestPhotosPermission() -> Future<PHAuthorizationStatus, Never> {
        return .init { future in
            future(.success(.authorized))
        }
    }
    
    func fetchAssets() -> [PHAsset] {
        return []
    }
}
