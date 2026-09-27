import XCTest

import Model
@testable import Home

final class HomeListStoreCellLayoutTests: XCTestCase {
    private typealias Layout = HomeListStoreCell.Layout

    private func makeBody(_ text: String) throws -> HomeListCardBody {
        let json = """
        {
            "text": { "text": "\(text)", "isHtml": false, "fontColor": "#5D5D5D" },
            "style": { "backgroundColor": "#F7F7F7" }
        }
        """
        return try JSONDecoder().decode(HomeListCardBody.self, from: Data(json.utf8))
    }

    // MARK: TH-1357 TC1 — 리뷰 미리보기 여러 개 노출

    func test_TH1357_TC1_리뷰가두개이상이면_고정폭카드로_모두노출한다() throws {
        // Given
        let bodies = [try makeBody("첫 번째 리뷰"), try makeBody("두 번째 리뷰")]

        // When
        let visibleBodies = Layout.visibleBodies(bodies)

        // Then
        XCTAssertEqual(visibleBodies.count, 2)
        XCTAssertEqual(Layout.bodyWidth(bodyCount: visibleBodies.count), Layout.multipleBodyWidth)
    }

    func test_TH1357_TC2_리뷰가하나면_기존처럼_가용폭전체를쓴다() {
        // Given / When
        let width = Layout.bodyWidth(bodyCount: 1)

        // Then
        XCTAssertEqual(width, Layout.imageAvailableWidth)
    }

    func test_TH1357_TC3_리뷰가여러개면_가장긴리뷰높이에맞춘다() throws {
        // Given
        let shortBody = try makeBody("짧은 리뷰")
        let longBody = try makeBody(String(repeating: "아주 긴 리뷰 내용입니다 ", count: 10))
        let labelWidth = Layout.multipleBodyWidth - Layout.bodyLabelInset * 2

        // When
        let height = Layout.bodiesHeight(bodies: [shortBody, longBody])

        // Then
        XCTAssertEqual(height, Layout.bodyHeight(body: longBody, labelWidth: labelWidth))
        XCTAssertGreaterThan(height, Layout.bodyHeight(body: shortBody, labelWidth: labelWidth))
    }

    func test_TH1357_TC4_텍스트가빈리뷰는_노출대상에서제외한다() throws {
        // Given
        let bodies = [try makeBody("리뷰"), try makeBody("")]

        // When
        let visibleBodies = Layout.visibleBodies(bodies)

        // Then
        XCTAssertEqual(visibleBodies.count, 1)
    }
}
