import Foundation
import XCTest

enum FixtureLoader {
    /// 테스트 번들의 JSON 픽스처를 디코딩한다. 픽스처는 dev 서버 실응답에서 캡처한다.
    static func decode<T: Decodable>(
        _ type: T.Type,
        from fileName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> T {
        let bundle = Bundle(for: BundleToken.self)
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("픽스처를 찾을 수 없습니다: \(fileName).json", file: file, line: line)
            throw FixtureError.notFound(fileName)
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }

    enum FixtureError: Error {
        case notFound(String)
    }
}

private final class BundleToken { }
