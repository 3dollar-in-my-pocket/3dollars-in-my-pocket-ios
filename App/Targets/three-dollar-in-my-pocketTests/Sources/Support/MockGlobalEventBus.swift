import Combine

import AppInterface

final class MockGlobalEventBus: GlobalEventBusProtocol {
    let onEditNickname = PassthroughSubject<String, Never>()
    let onReportStore = PassthroughSubject<Int, Never>()
}
