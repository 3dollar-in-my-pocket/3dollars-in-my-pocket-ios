import Foundation

public extension Result {
    var data: Success? {
        if case .success(let data) = self {
            return data
        } else {
            return nil
        }
    }
    
    var error: Error? {
        if case .failure(let error) = self {
            return error
        } else {
            return nil
        }
    }
}
