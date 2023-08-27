import Foundation

public extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
