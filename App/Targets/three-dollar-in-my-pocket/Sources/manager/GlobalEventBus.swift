import Combine

import AppInterface

final class GlobalEventBus: GlobalEventBusProtocol {
    static let shared = GlobalEventBus()
    
    var onEditNickname = PassthroughSubject<String, Never>()
    var onReportStore = PassthroughSubject<Int, Never>()
}
