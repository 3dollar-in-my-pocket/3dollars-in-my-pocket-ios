import Combine

public protocol GlobalEventBusProtocol {
    var onEditNickname: PassthroughSubject<String, Never> { get }
}
