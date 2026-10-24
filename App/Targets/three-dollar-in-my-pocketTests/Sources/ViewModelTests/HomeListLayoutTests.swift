import XCTest

@testable import Home

import FloatingPanel

final class HomeListLayoutTests: XCTestCase {
    func test_TH1534_TC1_기본레이아웃은_기존기본높이tip에서시작한다() {
        // Given & When
        let layout = HomeListLayout()

        // Then
        XCTAssertEqual(layout.initialState, .tip)
        XCTAssertEqual(HomeListLayout.Layout.tipVisibleHeight, 267)
    }

    func test_TH1534_TC2_접힘상태는_tip아래에핸들과탭높이로잡힌다() {
        // Given
        let collapsedHeight = HomeListView.Layout.collapsedVisibleHeight(hasTabs: true)

        // When
        let layout = HomeListLayout(collapsedVisibleHeight: collapsedHeight)

        // Then
        XCTAssertEqual(collapsedHeight, 80)
        XCTAssertEqual(layout.collapsedVisibleHeight, collapsedHeight)
        XCTAssertNotNil(layout.anchors[.collapsed])
        XCTAssertLessThan(FloatingPanelState.collapsed.order, FloatingPanelState.tip.order)
        XCTAssertEqual(Set(layout.anchors.keys), [.full, .tip, .collapsed])
    }

    func test_TH1534_TC2_탭이없으면_핸들영역만남긴다() {
        // Given & When
        let collapsedHeight = HomeListView.Layout.collapsedVisibleHeight(hasTabs: false)

        // Then
        XCTAssertEqual(collapsedHeight, 24)
        XCTAssertLessThan(collapsedHeight, HomeListView.Layout.collapsedVisibleHeight(hasTabs: true))
    }

    func test_TH1534_TC7_미리보기복원용레이아웃은_접힘상태와높이를유지한다() {
        // Given
        let collapsedHeight = HomeListView.Layout.collapsedVisibleHeight(hasTabs: true)

        // When
        let layout = HomeListLayout(initialState: .collapsed, collapsedVisibleHeight: collapsedHeight)

        // Then
        XCTAssertEqual(layout.initialState, .collapsed)
        XCTAssertEqual(layout.collapsedVisibleHeight, collapsedHeight)
    }
}
