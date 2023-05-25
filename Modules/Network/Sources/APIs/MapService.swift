import Foundation
import Combine

public protocol MapServiceProtocol {
    func getAddressFromLocation(latitude: Double, longitude: Double) -> AnyPublisher<String, Error>
    
    func searchAddress(keyword: String) -> AnyPublisher<LocalResponse<PlaceDocument>, Error>
    
    func getCurrentAddress(latitude: Double, longitude: Double) -> AnyPublisher<LocalResponse<AddressDocument>, Error>
}

public struct MapService: MapServiceProtocol {
    public init() { }
    
    public func getAddressFromLocation(latitude: Double, longitude: Double) -> AnyPublisher<String, Error> {
        var urlComponents = URLComponents(string: "https://naveropenapi.apigw.ntruss.com")
        urlComponents?.path = "/map-reversegeocode/v2/gc"
        urlComponents?.queryItems = [
            URLQueryItem(name: "request", value: "coordsToaddr"),
            URLQueryItem(name: "coords", value:  "\(longitude),\(latitude)"),
            URLQueryItem(name: "orders", value: "legalcode,admcode,addr,roadaddr"),
            URLQueryItem(name: "output", value: "json")
        ]
        
        guard let url = urlComponents?.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "X-NCP-APIGW-API-KEY-ID": "hqqqtcv85g",
            "X-NCP-APIGW-API-KEY": "Nk7L8VvCq9YkDuGPjvGDN8FW5ELfWTt23AgcS9ie"
        ]
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, _ in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let naverMapResponse = try? decoder.decode(NaverMapResponse.self, from: data) else {
                    throw NetworkError.decodingError
                }
                let address = naverMapResponse.address
                
                return address
            }.eraseToAnyPublisher()
    }
    
    public func searchAddress(keyword: String) -> AnyPublisher<LocalResponse<PlaceDocument>, Error> {
        var urlComponents = URLComponents(string: "https://dapi.kakao.com")
        urlComponents?.path = "/v2/local/search/keyword.json"
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "size", value:  String(10))
        ]
        
        guard let url = urlComponents?.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "KakaoAK 5bbbafb84c73c6be5b181b6f3d514129"
        ]
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, _ in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let localResponse = try? decoder.decode(LocalResponse<PlaceDocument>.self, from: data) else {
                    throw NetworkError.decodingError
                }
                return localResponse
            }.eraseToAnyPublisher()
    }
    
    public func getCurrentAddress(latitude: Double, longitude: Double) -> AnyPublisher<LocalResponse<AddressDocument>, Error> {
        var urlComponents = URLComponents(string: "https://dapi.kakao.com")
        urlComponents?.path = "/v2/local/geo/coord2address.json"
        urlComponents?.queryItems = [
            URLQueryItem(name: "x", value: String(latitude)),
            URLQueryItem(name: "y", value:  String(longitude))
        ]
        
        guard let url = urlComponents?.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "KakaoAK 5bbbafb84c73c6be5b181b6f3d514129"
        ]
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, _ in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                guard let localResponse = try? decoder.decode(LocalResponse<AddressDocument>.self, from: data) else {
                    throw NetworkError.decodingError
                }
                return localResponse
            }.eraseToAnyPublisher()
    }
}
