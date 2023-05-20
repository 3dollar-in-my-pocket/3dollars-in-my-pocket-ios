import Foundation
import OSLog

public final class NetworkLogger {
    public class func logRequest(request: URLRequest) {
        guard let urlString = request.url?.absoluteString,
              let headers = request.allHTTPHeaderFields
        else {
            os_log(.error, "⚠️올바른 URL형식이 아닙니다.")
            return
        }
        
        let message = """
        ============================================
        💚[NetworkModule -> RequestProvider]
        👉 URL: \(urlString)
        👉 Headers: \(headers.prettyString)
        👉 Data: \(request.httpBody?.prettyString ?? "null")
        ============================================
        """
        
        print(message)
    }

    public class func logResponse(response: URLResponse, data: Data) {
        guard let httpResponse = response as? HTTPURLResponse,
              let urlString = httpResponse.url?.absoluteString,
              let headers = httpResponse.allHeaderFields as? [String: String]
        else { return }
        
        let message = """
        ============================================
        💚[NetworkModule -> ResponseProvider]
        👉 Status: \(httpResponse.statusCode)
        👉 URL: \(urlString)
        👉 Headers: \(headers.prettyString)
        👉 Value: \(data.prettyString)
        ============================================
        """
        print(message)
    }
}

fileprivate extension Dictionary where Key == String {
    var prettyString: String {
        var result = ""
        for pair in self {
            result += "\n\t\(pair.key): \(pair.value),"
        }

        return result
    }
}

fileprivate extension Data {
    var prettyString: String {
        guard let jsonObject = try? JSONSerialization.jsonObject(
            with: self,
            options: []
        ) as? [String: Any] else {
            return "⚠️Fail convert to String"
        }

        return String(describing: jsonObject)
    }
}
