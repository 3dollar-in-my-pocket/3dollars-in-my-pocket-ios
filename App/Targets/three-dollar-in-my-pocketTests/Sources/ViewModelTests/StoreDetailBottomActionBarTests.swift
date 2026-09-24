import XCTest
import UIKit

@testable import Store

final class StoreDetailBottomActionBarTests: XCTestCase {
    private typealias Layout = StoreBottomActionBarView.Layout

    private let safeAreaBottom: CGFloat = 34
    private let staleTabBarInset: CGFloat = 49

    // MARK: TH-1336 TC1

    func test_TH1336_TC1_홈인디케이터가있으면_가리는높이는_safeArea만큼_더크다() {
        // Given / When
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: safeAreaBottom)

        // Then
        XCTAssertEqual(Layout.contentHeight, 64)
        XCTAssertEqual(coveringHeight, 98)
    }

    func test_TH1336_TC1_홈인디케이터가없으면_가리는높이는_contentHeight와같다() {
        // Given / When
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: 0)

        // Then
        XCTAssertEqual(coveringHeight, Layout.contentHeight)
    }

    // MARK: TH-1336 TC2 — 전체화면 호스트(contentInsetAdjustmentBehavior = .automatic)

    func test_TH1336_TC2_safeArea보정이자동적용되는호스트면_모자란만큼만_inset에넣는다() {
        // Given: 스크롤뷰가 이미 safe area 하단을 adjustedContentInset 에 더해 준 상태
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: safeAreaBottom)

        // When
        let inset = Layout.bottomContentInset(
            coveringHeight: coveringHeight,
            appliedAdjustment: safeAreaBottom
        )

        // Then: inset(64) + 자동 보정(34) = 가리는 높이(98)
        XCTAssertEqual(inset, 64)
        XCTAssertEqual(inset + safeAreaBottom, coveringHeight)
    }

    // MARK: TH-1336 TC3 — 홈 바텀시트 호스트(FloatingPanel 이 .never 로 바꿈)

    func test_TH1336_TC3_safeArea보정이없는호스트면_가리는높이전체를_inset에넣는다() {
        // Given: FloatingPanel 이 .never 로 바꿔 자동 보정이 0 인 상태
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: safeAreaBottom)

        // When
        let inset = Layout.bottomContentInset(
            coveringHeight: coveringHeight,
            appliedAdjustment: 0
        )

        // Then: 버그 이전에는 64 라서 34 만큼 컨텐츠가 가려졌다.
        XCTAssertEqual(inset, 98)
        XCTAssertEqual(inset, coveringHeight)
    }

    func test_TH1336_TC3_FloatingPanel이_inset을덮어써도_계산결과는동일하다() {
        // Given
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: safeAreaBottom)

        // When: FloatingPanel 이 덮어쓴 값(34)에서 다시 계산해도 보정량은 여전히 0
        let recovered = Layout.bottomContentInset(
            coveringHeight: coveringHeight,
            appliedAdjustment: 0
        )

        // Then
        XCTAssertEqual(recovered, coveringHeight)
    }

    // MARK: TH-1336 TC4

    func test_TH1336_TC4_액션바가없으면_inset은0이다() {
        // Given / When
        let inset = Layout.bottomContentInset(coveringHeight: 0, appliedAdjustment: 0)

        // Then
        XCTAssertEqual(inset, 0)
    }

    // MARK: TH-1336 TC5

    func test_TH1336_TC5_이미적용된보정이_가리는높이보다크면_음수가아니라0이다() {
        // Given / When
        let inset = Layout.bottomContentInset(coveringHeight: 64, appliedAdjustment: 120)

        // Then
        XCTAssertEqual(inset, 0)
    }

    // MARK: TH-1336 TC6

    func test_TH1336_TC6_윈도우에붙어있으면_상속된safeArea대신_윈도우값을쓴다() {
        // Given / When
        let inset = Layout.bottomSafeAreaInset(windowSafeAreaBottom: 34, inheritedSafeAreaBottom: 83)

        // Then
        XCTAssertEqual(inset, 34)
    }

    func test_TH1336_TC6_윈도우에붙기전이면_상속된safeArea를쓴다() {
        // Given / When
        let inset = Layout.bottomSafeAreaInset(windowSafeAreaBottom: nil, inheritedSafeAreaBottom: 34)

        // Then
        XCTAssertEqual(inset, 34)
    }

    // MARK: TH-1336 TC7

    func test_TH1336_TC7_탭바가숨겨져_상속된safeArea가커져도_바높이는윈도우기준이다() {
        // Given
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 874))
        let viewController = UIViewController()
        let bar = StoreBottomActionBarView()
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        bar.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        viewController.additionalSafeAreaInsets.bottom = staleTabBarInset

        // When
        window.layoutIfNeeded()

        // Then
        let windowSafeAreaBottom = window.safeAreaInsets.bottom
        XCTAssertEqual(
            viewController.view.safeAreaInsets.bottom,
            windowSafeAreaBottom + staleTabBarInset,
            accuracy: 0.5
        )
        XCTAssertEqual(bar.frame.height, Layout.contentHeight + windowSafeAreaBottom, accuracy: 0.5)
        XCTAssertEqual(bar.coveringHeight, Layout.contentHeight + windowSafeAreaBottom, accuracy: 0.5)
    }

    // MARK: TH-1336 TC8

    func test_TH1336_TC8_탭바높이만큼_보정된호스트에서도_총보정은_가리는높이와같다() {
        // Given
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: safeAreaBottom)
        let appliedAdjustment = safeAreaBottom + staleTabBarInset

        // When
        let inset = Layout.bottomContentInset(
            coveringHeight: coveringHeight,
            appliedAdjustment: appliedAdjustment
        )

        // Then
        XCTAssertEqual(inset, 15)
        XCTAssertEqual(inset + appliedAdjustment, coveringHeight)
    }
}
