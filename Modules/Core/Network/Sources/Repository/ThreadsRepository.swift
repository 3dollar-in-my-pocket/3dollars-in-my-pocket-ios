import Foundation

import Model

public protocol ThreadsRepository {
    func fetchOEmbed(url: String) async -> Result<ThreadsOEmbedResponse, Error>
}

public struct ThreadsRepositoryImpl: ThreadsRepository {
    private static let oEmbedEndpoint = "https://graph.threads.net/v1.0/oembed"
    private static let timeoutInterval: TimeInterval = 10

    public init() { }

    public func fetchOEmbed(url: String) async -> Result<ThreadsOEmbedResponse, Error> {
        var components = URLComponents(string: Self.oEmbedEndpoint)
        components?.queryItems = [URLQueryItem(name: "url", value: url)]
        guard let requestURL = components?.url else { return .failure(NetworkError.invalidURL) }

        let request = URLRequest(url: requestURL, timeoutInterval: Self.timeoutInterval)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return .failure(NetworkError.noData) }
            let oEmbed = try JSONDecoder().decode(ThreadsOEmbedResponse.self, from: data)
            guard !oEmbed.html.isEmpty else { return .failure(NetworkError.noData) }
            return .success(oEmbed)
        } catch {
            return .failure(error)
        }
    }
}
