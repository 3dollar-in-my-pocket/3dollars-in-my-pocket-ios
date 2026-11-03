import XCTest

@testable import dollar_in_my_pocket

final class AdUnitIdResolverTests: XCTestCase {
    private let fallbackUnitId = "ca-app-pub-0000000000000000/1111111111"
    private let serverUnitId = "ca-app-pub-5385646520024289/9943824572"

    func test_TH1564_TC3_Release에서서버adUnitId가있으면_서버값을쓴다() {
        // When
        let unitId = AdUnitIdResolver.resolve(
            serverAdUnitId: serverUnitId,
            fallback: fallbackUnitId,
            usesServerAdUnitId: true
        )

        // Then
        XCTAssertEqual(unitId, serverUnitId)
    }

    func test_TH1564_TC4_Release에서서버adUnitId가nil이면_기존유닛을쓴다() {
        // When
        let unitId = AdUnitIdResolver.resolve(serverAdUnitId: nil, fallback: fallbackUnitId, usesServerAdUnitId: true)

        // Then
        XCTAssertEqual(unitId, fallbackUnitId)
    }

    func test_TH1564_TC4_Release에서서버adUnitId가빈문자열이면_기존유닛을쓴다() {
        // When
        let unitId = AdUnitIdResolver.resolve(serverAdUnitId: "  ", fallback: fallbackUnitId, usesServerAdUnitId: true)

        // Then
        XCTAssertEqual(unitId, fallbackUnitId)
    }

    func test_TH1564_TC5_Debug에서서버adUnitId가있어도_테스트유닛을쓴다() {
        // When
        let unitId = AdUnitIdResolver.resolve(
            serverAdUnitId: serverUnitId,
            fallback: fallbackUnitId,
            usesServerAdUnitId: false
        )

        // Then
        XCTAssertEqual(unitId, fallbackUnitId)
    }
}
