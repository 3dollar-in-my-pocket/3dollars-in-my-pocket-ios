import Foundation
import Combine

import DependencyInjection
import Model
import Common

final public class NetworkManager {
    public static let shared = NetworkManager()
    
    private let requestProvider: RequestProvider
    private let responseProvider: ResponseProvider

    public init() {
        self.requestProvider = RequestProvider()
        self.responseProvider = ResponseProvider()
    }

    public func request<T: Decodable>(requestType: RequestType) async -> Result<T, Error> {
        do {
            // 실험 컨텍스트 헤더가 추가된 RequestType 생성
            let modifiedRequestType = RequestTypeWithExperimentContext(
                originalRequestType: requestType,
                experimentContext: RemoteConfigManager.shared.experimentContext
            )
            
            let response = try await requestProvider.request(requestType: modifiedRequestType)
            let data: T = try responseProvider.processResponse(data: response.0, response: response.1)
            
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

// RequestType을 감싸서 실험 컨텍스트 헤더를 추가하는 래퍼
private struct RequestTypeWithExperimentContext: RequestType {
    private let originalRequestType: RequestType
    private let experimentContext: String
    
    init(originalRequestType: RequestType, experimentContext: String) {
        self.originalRequestType = originalRequestType
        self.experimentContext = experimentContext
    }
    
    var param: Encodable? { originalRequestType.param }
    var method: RequestMethod { originalRequestType.method }
    var path: String { originalRequestType.path }
    var task: HTTPTask { originalRequestType.task }
    
    var header: HTTPHeaderType {
        // 기존 헤더에 실험 컨텍스트 헤더 추가
        if experimentContext.isEmpty {
            return originalRequestType.header
        }
        
        switch originalRequestType.header {
        case .json:
            return .custom(["Experiment-Context": experimentContext])
        case .location:
            return .custom(["Experiment-Context": experimentContext])
        case .custom(let headers):
            var newHeaders = headers
            newHeaders["Experiment-Context"] = experimentContext
            return .custom(newHeaders)
        }
    }
}

extension Result {
    func publish() -> AnyPublisher<Success, Failure> {
        return Result.Publisher(self).eraseToAnyPublisher()
    }
}
