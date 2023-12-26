import Foundation
import Combine

public final class MockTokenService {
    public init() { }
    
    public func generateTeestToken(completion: @escaping ((MockAuth) -> Void))  {
        let urlString = "https://dev.threedollars.co.kr/api/test-token"
        guard let url = URL(string: urlString) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "get"
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data else { return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            guard let mockAuth = try? decoder.decode(MockAuth.self, from: data) else { return }
            completion(mockAuth)
        }.resume()
    }
}
