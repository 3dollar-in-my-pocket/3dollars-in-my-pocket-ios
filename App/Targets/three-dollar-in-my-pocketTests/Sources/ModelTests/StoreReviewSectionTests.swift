import XCTest

import Model

final class StoreReviewSectionTests: XCTestCase {
    func test_블라인드된리뷰카드가_헤더없이내려와도_응답전체가디코딩된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(StoreScreenV2Response.self, from: "StoreScreenV2WithBlindedReview")

        // Then
        let review = try XCTUnwrap(response.sections.compactMap { $0 as? StoreReviewSection }.first)
        XCTAssertEqual(review.cards.count, 3)

        let normalCard = try XCTUnwrap(review.cards.first)
        XCTAssertNotNil(normalCard.header)
        XCTAssertNotNil(normalCard.stars)

        let blindedCard = try XCTUnwrap(review.cards.last)
        XCTAssertNil(blindedCard.header)
        XCTAssertNil(blindedCard.metadata)
        XCTAssertNil(blindedCard.stars)
        XCTAssertNil(blindedCard.like)
        XCTAssertTrue(blindedCard.body.text.contains("블라인드"))
        XCTAssertEqual(blindedCard.style.backgroundColor, "#F4F4F4")
    }
}
