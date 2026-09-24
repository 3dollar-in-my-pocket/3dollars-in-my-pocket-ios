import XCTest

@testable import Home

final class HomeListMapButtonTests: XCTestCase {
    private typealias Layout = HomeListView.Layout

    private let homeIndicatorInset: CGFloat = 34
    private let tabBarHeight: CGFloat = 83
    private let buttonBottomInset: CGFloat = MapViewButton.Layout.bottomInset

    // MARK: TH-1232 TC2 — 지도 보기 버튼 위치

    func test_TH1232_TC2_탭바가보이면_탭바높이만큼_띄운다() {
        // Given / When
        let inset = Layout.mapButtonBottomInset(
            safeAreaBottom: tabBarHeight,
            bottomBarCoveringHeight: tabBarHeight
        )

        // Then
        XCTAssertEqual(inset, tabBarHeight + buttonBottomInset)
    }

    func test_TH1232_TC2_상속된safeArea가_탭바높이로복구되지않아도_탭바위에머문다() {
        // Given / When
        let inset = Layout.mapButtonBottomInset(
            safeAreaBottom: homeIndicatorInset,
            bottomBarCoveringHeight: tabBarHeight
        )

        // Then
        XCTAssertEqual(inset, tabBarHeight + buttonBottomInset)
        XCTAssertNotEqual(inset, homeIndicatorInset + buttonBottomInset)
    }

    func test_TH1232_TC2_탭바가숨겨져있으면_홈인디케이터만큼만_띄운다() {
        // Given / When
        let inset = Layout.mapButtonBottomInset(
            safeAreaBottom: homeIndicatorInset,
            bottomBarCoveringHeight: homeIndicatorInset
        )

        // Then
        XCTAssertEqual(inset, homeIndicatorInset + buttonBottomInset)
    }

    func test_TH1232_TC2_상속된safeArea가_가려지는높이보다크면_큰값을따른다() {
        // Given / When
        let inset = Layout.mapButtonBottomInset(safeAreaBottom: 120, bottomBarCoveringHeight: tabBarHeight)

        // Then
        XCTAssertEqual(inset, 120 + buttonBottomInset)
    }
}
