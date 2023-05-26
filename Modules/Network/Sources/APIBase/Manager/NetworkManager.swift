import Foundation
import Combine

final public class NetworkManager {
    public static let shared = NetworkManager(config: NetworkConfiguration.defaultConfig)
    
    public var configuration: NetworkConfiguration {
        didSet(newValue) {
            requestProvider.config = newValue
        }
    }
    private let requestProvider: RequestProvider
    private let responseProvider: ResponseProvider

    public init(config: NetworkConfiguration) {
        self.configuration = config
        self.requestProvider = RequestProvider(config: config)
        self.responseProvider = ResponseProvider()
    }

    public func request<T: Decodable>(requestType: RequestType) async -> Result<T, Error> {
        do {
            let response = try await requestProvider.request(requestType: requestType)
            let data: T = try responseProvider.processResponse(data: response.0, response: response.1)
            
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

extension Result {
    func publish() -> AnyPublisher<Success, Failure> {
        return Result.Publisher(self).eraseToAnyPublisher()
    }
}
