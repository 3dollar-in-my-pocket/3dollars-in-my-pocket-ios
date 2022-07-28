import Foundation

import RxSwift

final class GlobalState {
    static let shared = GlobalState()
    
    let updateStore = PublishSubject<StoreProtocol>()
}
