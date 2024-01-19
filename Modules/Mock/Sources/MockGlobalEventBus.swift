import Combine

import AppInterface

final class MockGlobalEventBus: GlobalEventBusProtocol {
    static let shared = MockGlobalEventBus()
    
    var onEditNickname = PassthroughSubject<String, Never>()
}
