import Foundation

import Model
import Networking

final class MockThreadsRepository: ThreadsRepository {
    var htmlsByURL: [String: String] = [:]
    private(set) var requestedURLs: [String] = []

    init(htmlsByURL: [String: String] = [:]) {
        self.htmlsByURL = htmlsByURL
    }

    func fetchOEmbed(url: String) async -> Result<ThreadsOEmbedResponse, Error> {
        requestedURLs.append(url)
        guard let html = htmlsByURL[url] else { return .failure(MockError.notStubbed()) }
        let json = try? JSONSerialization.data(withJSONObject: ["html": html])
        guard let json, let response = try? JSONDecoder().decode(ThreadsOEmbedResponse.self, from: json) else {
            return .failure(MockError.notStubbed())
        }
        return .success(response)
    }
}
