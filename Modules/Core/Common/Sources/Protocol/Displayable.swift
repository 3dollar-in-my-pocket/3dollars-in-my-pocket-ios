import Foundation

public protocol Displayable {
    func didEndDisplaying()
    
    func willDisplay()
}

public extension Displayable {
    func didEndDisplaying() { }
    
    func willDisplay() { }
}
