import Foundation

final class ResponseProvider {
    func processResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        NetworkLogger.logResponse(response: response, data: data)
        
        if response.isSuccess {
            do {
                let responseContainer: ResponseContainer<T> = try decode(data: data)
                guard let data = responseContainer.data else { throw NetworkError.noData }
                
                return data
            } catch {
                throw error
            }
        } else {
            if let errorContainer = decodeError(data: data) {
                throw NetworkError.message(errorContainer.message)
            } else {
                throw response.httpError
            }
        }
    }

    private func decode<T: Decodable>(data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let result = try decoder.decode(T.self, from: data)
            
            return result
        } catch {
            print("⛔️[ResponseProvider]: Decoding error\n\(error)")
            throw NetworkError.decodingError
        }
    }
    
    private func decodeError(data: Data) -> ResponseContainer<String>? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try? decoder.decode(ResponseContainer<String>.self, from: data)
    }
}

extension URLResponse {
    var isSuccess: Bool {
        guard let httpResponse = self as? HTTPURLResponse,
              httpResponse.statusCode == 200 else { return false }
        return true
    }
    
    var httpError: HTTPError {
        guard let httpResponse = self as? HTTPURLResponse else { return .unknown }
        
        return HTTPError(fromRawValue: httpResponse.statusCode)
    }
}
