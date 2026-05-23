import UIKit

import FloatingPanel

/// StorePreview 바텀시트의 단계 레이아웃.
/// - `.tip`: 미리보기 카드가 safeArea bottom 위로 고정 높이만큼 노출되는 상태.
/// - `.full`: 추후 상세 스크롤 컨텐츠가 붙으면 활성화 예정 (현재는 미사용).
final class StorePreviewLayout: FloatingPanelLayout {
    enum Layout {
        /// 미리보기 카드 worst-case 높이 (이미지/바디/액션바 모두 포함).
        static let tipVisibleHeight: CGFloat = 400
    }

    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip

    let anchors: [FloatingPanelState: any FloatingPanelLayoutAnchoring] = [
        .tip: FloatingPanelLayoutAnchor(
            absoluteInset: Layout.tipVisibleHeight,
            edge: .bottom,
            referenceGuide: .safeArea
        )
    ]
}
