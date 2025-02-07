import UIKit

import Alamofire

import Model

public protocol ImageUploadServiceType {
    func uploadImages(datas: [Data], fileType: FileType) async -> Result<[ImageUploadResponse], Error>
}

public final class ImageUploadService: ImageUploadServiceType {
    public init() { }
    
    public func uploadImages(datas: [Data], fileType: FileType) async -> Result<[ImageUploadResponse], Error> {
        let request = UploadImageRequest(photos: datas, fileType: fileType)
        
        return await NetworkManager.shared.request(requestType: request)
    }
}
