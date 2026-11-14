import UIKit
import XCTest

import Model
@testable import Store

@MainActor
final class StorePreviewMorePeekTests: XCTestCase {
    // MARK: TH-1583 TC1

    func test_TH1583_TC1_PREVIEW_MORE가있으면_시트높이가그셀윗부분까지만잡힌다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")
        let (view, heights) = makeView(style: .preview)

        // When
        view.apply(response.sections)
        view.layoutIfNeeded()

        // Then
        let lastIndex = IndexPath(item: response.sections.count - 1, section: 0)
        let previewMoreFrame = try XCTUnwrap(view.collectionView.layoutAttributesForItem(at: lastIndex)?.frame)
        let reported = try XCTUnwrap(heights.values.last)
        XCTAssertEqual(reported, previewMoreFrame.minY + StorePreviewMoreCell.Layout.peekHeight, accuracy: 0.5)
        XCTAssertLessThan(reported, previewMoreFrame.maxY)
        XCTAssertTrue(view.isPeekingNextSection)
    }

    // MARK: TH-1583 TC2

    func test_TH1583_TC2_상세화면에는_PREVIEW_MORE섹션을그리지않는다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")
        let (view, _) = makeView(style: .detail)

        // When
        view.apply(response.sections)

        // Then
        XCTAssertFalse(view.sections.contains { $0 is StorePreviewMoreSection })
        XCTAssertEqual(view.sections.count, response.sections.count - 1)
    }

    // MARK: TH-1583 TC3

    func test_TH1583_TC3_PREVIEW_MORE가없으면_시트높이는컨텐츠전체높이다() throws {
        // Given
        let response = try FixtureLoader.decode(StorePreviewScreenResponse.self, from: "StorePreviewWithAdmob")
        let sections = response.sections.filter { ($0 is StorePreviewMoreSection) == false }
        let (view, heights) = makeView(style: .preview)

        // When
        view.apply(sections)
        view.layoutIfNeeded()

        // Then
        let reported = try XCTUnwrap(heights.values.last)
        XCTAssertEqual(reported, view.collectionView.contentSize.height, accuracy: 0.5)
        XCTAssertFalse(view.isPeekingNextSection)
    }

    private final class HeightRecorder {
        var values: [CGFloat] = []
    }

    private func makeView(style: StoreSectionsView.Style) -> (StoreSectionsView, HeightRecorder) {
        let view = StoreSectionsView(style: style)
        view.frame = CGRect(x: 0, y: 0, width: 393, height: 2000)
        let recorder = HeightRecorder()
        view.onContentHeightChanged = { recorder.values.append($0) }
        return (view, recorder)
    }
}
