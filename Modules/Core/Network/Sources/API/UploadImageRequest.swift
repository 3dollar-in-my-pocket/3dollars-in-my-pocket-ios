import Foundation
import UIKit

import Model

struct UploadImageRequest: MultipartRequestType {
    let boundary = UUID().uuidString
    let photos: [Data]
    let fileType: FileType
    
    var path: String {
        return "/api/v1/upload/\(fileType.rawValue)/bulk"
    }
    
    var data: Data {
        return getPhotoData()
    }
    
    private func getPhotoData() -> Data {
        let data = NSMutableData()
        
        // Append attributes
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"fileType\"\r\n")
        data.appendString("\r\n")
        data.appendString("\(fileType.rawValue)\r\n")
        
        // Append Photo data
        for photo in photos {
            data.appendString("--\(boundary)\r\n")
            data.appendString("Content-Disposition: form-data; name=\"files\"; filename=\"image.jpeg\"\r\n")
            data.appendString("Content-Type: image/jpeg\r\n\r\n")
            data.append(photo)
            data.appendString("\r\n")
        }
        data.appendString("--\(boundary)--")
        return data as Data
    }
}
