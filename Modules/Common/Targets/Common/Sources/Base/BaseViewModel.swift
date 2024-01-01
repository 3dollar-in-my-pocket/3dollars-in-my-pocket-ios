import Foundation
import Combine

open class BaseViewModel {
    public var cancellables = Set<AnyCancellable>()
    public var taskBag = AnyCancelTaskBag()
    
    public init() {
        bind()
    }
    
    open func bind() { }
}
