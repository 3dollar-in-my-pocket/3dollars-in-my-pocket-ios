import XCTest

@testable import Home
import Model

final class HomeMarkerIconTests: XCTestCase {
    func test_TH1532_TC4_서버alpha가0과1사이면_그값을마커투명도로쓴다() {
        // Given
        let style = SDImageStyle(width: 28, height: 28, alpha: 0.4)

        // When
        let alpha = HomeMarkerIcon.alpha(of: style)

        // Then
        XCTAssertEqual(alpha, 0.4, accuracy: 0.0001)
    }

    func test_TH1532_TC5_서버alpha가0이면_하한없이0을쓴다() {
        // Given
        let style = SDImageStyle(width: 28, height: 28, alpha: 0.0)

        // When
        let alpha = HomeMarkerIcon.alpha(of: style)

        // Then
        XCTAssertEqual(alpha, 0.0)
    }

    func test_TH1532_TC7_alpha가없는응답이나이미지가없는마커는_불투명하다() {
        // Given
        let styleWithoutAlpha = SDImageStyle(width: 28, height: 28)

        // When & Then
        XCTAssertEqual(HomeMarkerIcon.alpha(of: styleWithoutAlpha), 1.0)
        XCTAssertEqual(HomeMarkerIcon.alpha(of: nil), 1.0)
    }

    func test_TH1532_TC4_범위를벗어난alpha는_0과1사이로자른다() {
        // Given
        let over = SDImageStyle(width: 28, height: 28, alpha: 1.5)
        let under = SDImageStyle(width: 28, height: 28, alpha: -0.2)

        // When & Then
        XCTAssertEqual(HomeMarkerIcon.alpha(of: over), 1.0)
        XCTAssertEqual(HomeMarkerIcon.alpha(of: under), 0.0)
    }
}
