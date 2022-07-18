import Foundation

struct JsonUtils {
    static func toJson<T: Decodable>(object: Any) -> T? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: object) {
            let decoder = JSONDecoder()
            let result = try? decoder.decode(T.self, from: jsonData)
            
            return result
        } else {
            return nil
        }
    }
    
    static func decode<T: Decodable>(data: Data) -> T? {
        let decoder = JSONDecoder()
        let result = try? decoder.decode(T.self, from: data)
        
        return result
    }
}
