import UIKit

import FloatingPanel

/// StorePreview 바텀시트의 단계 레이아웃.
/// - `.tip`: 미리보기 카드가 safeArea bottom 위로 `visibleHeight` 만큼 노출되는 상태.
///   이미지/바디 유무에 따라 컨텐츠 높이가 달라지므로 외부에서 주입한다.
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
            )
        ]
    }

    init(visibleHeight: CGFloat = Layout.defaultVisibleHeight) {
        self.visibleHeight = visibleHeight
    }
}
