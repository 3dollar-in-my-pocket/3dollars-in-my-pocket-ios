import UIKit

import FloatingPanel

/// StorePreview 바텀시트의 단계 레이아웃.
/// - `.tip`: 미리보기 카드가 safeArea bottom 위로 `visibleHeight` 만큼 노출되는 상태.
/// - `.full`: 같은 surface 를 화면 최상단까지 확장해 V2 상세 컨텐츠를 스크롤한다.
final class StorePreviewLayout: FloatingPanelLayout {
    enum Layout {
        /// 컨텐츠 계산에 실패했을 때 사용할 안전 기본값 (worst-case 높이).
        static let defaultVisibleHeight: CGFloat = 400
    }

    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip

    private let visibleHeight: CGFloat

    var anchors: [FloatingPanelState: any FloatingPanelLayoutAnchoring] {
        [
            .tip: FloatingPanelLayoutAnchor(
                absoluteInset: visibleHeight,
                edge: .bottom,
                referenceGuide: .safeArea
            ),
            .full: FloatingPanelLayoutAnchor(
                absoluteInset: 0,
                edge: .top,
                referenceGuide: .superview
            )
        ]
    }

    init(visibleHeight: CGFloat = Layout.defaultVisibleHeight) {
        self.visibleHeight = visibleHeight
    }
}
