import XCTest

import Model

final class SDImageStyleTests: XCTestCase {
    func test_dimmed가없으면_false로디코딩된다() throws {
        // Given
        let json = """
        { "url": "https://example.com/a.png", "style": { "width": 100, "height": 100 } }
        """

        // When
        let image = try JSONDecoder().decode(SDImage.self, from: Data(json.utf8))

        // Then
        XCTAssertFalse(image.style.dimmed)
        XCTAssertEqual(image.style.width, 100)
        XCTAssertEqual(image.style.height, 100)
    }

    func test_dimmed가true면_그대로디코딩된다() throws {
        // Given
        let json = """
        { "url": "https://example.com/a.png", "style": { "width": 100, "height": 100, "dimmed": true } }
        """

        // When
        let image = try JSONDecoder().decode(SDImage.self, from: Data(json.utf8))

        // Then
        XCTAssertTrue(image.style.dimmed)
    }

    func test_TH1532_TC1_alpha가없으면_1로디코딩된다() throws {
        // Given
        let json = """
        { "url": "https://example.com/a.png", "style": { "width": 100, "height": 100 } }
        """

        // When
        let image = try JSONDecoder().decode(SDImage.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(image.style.alpha, 1.0)
    }

    func test_TH1532_TC2_alpha가있으면_그값으로디코딩된다() throws {
        // Given
        let json = """
        { "url": "https://example.com/a.png", "style": { "width": 100, "height": 100, "dimmed": false, "alpha": 0.5 } }
        """

        // When
        let image = try JSONDecoder().decode(SDImage.self, from: Data(json.utf8))

        // Then
        XCTAssertEqual(image.style.alpha, 0.5)
    }
}
