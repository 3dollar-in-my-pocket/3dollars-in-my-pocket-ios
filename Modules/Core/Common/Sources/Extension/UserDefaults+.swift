import Foundation

public extension UserDefaults {
    func set(encodable: Encodable, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(encodable) {
            self.set(encoded, forKey: key)
        }
    }
    
    func getData<T: Decodable>(forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        
        guard let decodable = try? decoder.decode(T.self, from: data) else { return nil }
        return decodable
    }
}
