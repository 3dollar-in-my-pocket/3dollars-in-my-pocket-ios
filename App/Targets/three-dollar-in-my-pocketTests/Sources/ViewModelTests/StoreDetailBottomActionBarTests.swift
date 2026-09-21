import XCTest

@testable import Store

/// 가게 상세 하단 액션바(방문 인증·리뷰 작성·공유·길안내 chip)가 컨텐츠를 가리지 않는지 검증한다.
///
/// TH-1336: 바는 superview 하단(safe area 바깥)까지 깔리는데 컬렉션뷰 하단 inset 은
/// safe area 를 뺀 높이(64)만 잡고 있었다. 게다가 홈 바텀시트 호스트에서는 FloatingPanel 이
/// tracking scrollView 의 `contentInsetAdjustmentBehavior` 를 `.never` 로 바꾸고
/// contentInset 을 자기 값으로 덮어써서, safe area 보정이 붙는지가 호스트마다 달랐다.
final class StoreDetailBottomActionBarTests: XCTestCase {
    private typealias Layout = StoreBottomActionBarView.Layout

    /// 홈 인디케이터가 있는 기기(safe area 하단 34)에서 실제로 컨텐츠를 가리는 높이.
    private let safeAreaBottom: CGFloat = 34

    // MARK: TC1

    func test_TC1_홈인디케이터가있으면_가리는높이는_safeArea만큼_더크다() {
        // Given / When
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: safeAreaBottom)

        // Then
        XCTAssertEqual(Layout.contentHeight, 64)
        XCTAssertEqual(coveringHeight, 98)
    }

    func test_TC1_홈인디케이터가없으면_가리는높이는_contentHeight와같다() {
        // Given / When
        let coveringHeight = Layout.coveringHeight(safeAreaBottom: 0)

        // Then
        XCTAssertEqual(coveringHeight, Layout.contentHeight)
    }

    // MARK: TC2 — 전체화면 호스트(contentInsetAdjustmentBehavior = .automatic)

    func test_TC2_safeArea보정이자동적용되는호스트면_모자란만큼만_inset에넣는다() {
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

    // MARK: TC3 — 홈 바텀시트 호스트(FloatingPanel 이 .never 로 바꿈)

    func test_TC3_safeArea보정이없는호스트면_가리는높이전체를_inset에넣는다() {
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

    /// FloatingPanel 이 contentInset 을 safe area 하단으로 덮어쓴 직후에도
    /// 다음 레이아웃 패스에서 같은 값으로 복구돼야 한다.
    func test_TC3_FloatingPanel이_inset을덮어써도_계산결과는동일하다() {
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

    // MARK: TC4

    func test_TC4_액션바가없으면_inset은0이다() {
        // Given / When
        let inset = Layout.bottomContentInset(coveringHeight: 0, appliedAdjustment: 0)

        // Then
        XCTAssertEqual(inset, 0)
    }

    // MARK: TC5

    func test_TC5_이미적용된보정이_가리는높이보다크면_음수가아니라0이다() {
        // Given / When
        let inset = Layout.bottomContentInset(coveringHeight: 64, appliedAdjustment: 120)

        // Then
        XCTAssertEqual(inset, 0)
    }
}
