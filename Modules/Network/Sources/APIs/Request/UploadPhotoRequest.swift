import Foundation
import UIKit

import Model

struct UploadPhotoRequest: MultipartRequestType {
    let boundary = UUID().uuidString
    let storeId: Int
    let photos: [Data]
    
    var path: String {
        return "/api/v2/store/images"
    }
    
    var data: Data {
        return getPhotoData()
    }
    
    private func getPhotoData() -> Data {
        let data = NSMutableData()
        
        // Append attributes
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"storeId\"\r\n")
        data.appendString("\r\n")
        data.appendString("\(storeId)\r\n")
        
        // Append Photo data
        for photo in photos {
            data.appendString("--\(boundary)\r\n")
            data.appendString("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpeg\"\r\n")
            data.appendString("Content-Type: image/jpeg\r\n\r\n")
            data.append(photo)
            data.appendString("\r\n")
        }
        data.appendString("--\(boundary)--")
        return data as Data
    }
}
