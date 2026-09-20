import XCTest

import Model

final class HomeListSectionResponseTests: XCTestCase {
    func test_이벤트가게필터응답을디코딩하면_focusBounds가파싱된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeListSectionResponse.self,
            from: "HomeListSectionWithFocusBounds"
        )

        // Then
        let focusBounds = try XCTUnwrap(response.focusBounds)
        XCTAssertEqual(focusBounds.southWest.latitude, 37.56566954184981, accuracy: 0.000001)
        XCTAssertEqual(focusBounds.southWest.longitude, 126.977966, accuracy: 0.000001)
        XCTAssertEqual(focusBounds.northEast.latitude, 37.5666, accuracy: 0.000001)
        XCTAssertEqual(focusBounds.northEast.longitude, 126.97871680558559, accuracy: 0.000001)
    }

    func test_focusBounds가없는응답을디코딩하면_nil이고기존필드는유지된다() throws {
        // Given & When
        let response = try FixtureLoader.decode(
            HomeListSectionResponse.self,
            from: "HomeListSectionWithoutFocusBounds"
        )

        // Then
        XCTAssertNil(response.focusBounds)
        XCTAssertFalse(response.cards.isEmpty)
        XCTAssertEqual(response.cursor?.hasMore, true)
        XCTAssertNotNil(response.cursor?.nextCursor)
    }

    func test_focusBounds가있어도_카드와커서파싱은그대로동작한다() throws {
        // Given & When
        let withBounds = try FixtureLoader.decode(
            HomeListSectionResponse.self,
            from: "HomeListSectionWithFocusBounds"
        )
        let withoutBounds = try FixtureLoader.decode(
            HomeListSectionResponse.self,
            from: "HomeListSectionWithoutFocusBounds"
        )

        // Then
        XCTAssertEqual(withBounds.cards.count, withoutBounds.cards.count)
        XCTAssertEqual(
            withBounds.cards.map(\.cardId),
            withoutBounds.cards.map(\.cardId)
        )
        XCTAssertEqual(withBounds.cursor?.nextCursor, withoutBounds.cursor?.nextCursor)
    }

    func test_남서북동좌표가같은focusBounds도_디코딩된다() throws {
        // Given
        let json = """
        {
            "cards": [],
            "cursor": { "nextCursor": null, "hasMore": false },
            "focusBounds": {
                "southWest": { "latitude": 37.5665, "longitude": 126.978 },
                "northEast": { "latitude": 37.5665, "longitude": 126.978 }
            }
        }
        """

        // When
        let response = try JSONDecoder().decode(
            HomeListSectionResponse.self,
            from: XCTUnwrap(json.data(using: .utf8))
        )

        // Then
        let focusBounds = try XCTUnwrap(response.focusBounds)
        XCTAssertEqual(focusBounds.southWest, focusBounds.northEast)
        XCTAssertTrue(response.cards.isEmpty)
        XCTAssertEqual(response.cursor?.hasMore, false)
    }
}
