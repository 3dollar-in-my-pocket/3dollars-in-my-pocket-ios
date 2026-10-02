import Foundation

import Model

struct StoreMenuExtractionRequest: MultipartRequestType {
    let boundary = UUID().uuidString
    let image: Data

    var path: String {
        return "/api/v1/store-menu-extractions"
    }

    var timeoutInterval: TimeInterval? {
        return 60
    }

    var data: Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"menu.jpeg\"\r\n")
        data.appendString("Content-Type: image/jpeg\r\n\r\n")
        data.append(image)
        data.appendString("\r\n")
        data.appendString("--\(boundary)--")
        return data as Data
    }
}
