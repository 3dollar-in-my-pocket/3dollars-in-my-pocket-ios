import UIKit

import FloatingPanel

extension FloatingPanelState {
    static let collapsed = FloatingPanelState(rawValue: "collapsed", order: 50)
}

/// 홈 바텀시트의 collapsed / short(.tip) / long(.full) 세 단계 레이아웃.
/// - `.collapsed`: 핸들·탭 영역만 보이도록 safeArea bottom 기준으로 잡는다. 지도를 크게 볼 때 쓴다.
/// - `.tip`: 탭바 위로 267pt 만큼 보이도록 safeArea bottom 기준으로 잡는다 (탭바는 safeArea 밖이므로 자연스럽게 탭바 뒤로 surface 가 깔린다).
/// - `.full`: safeArea top 기준 108pt(주소 버튼 48 + 필터 60) 아래에 멈춰서 상단의 주소/필터 영역을 가리지 않도록 한다.
final class HomeListLayout: FloatingPanelLayout {
    enum Layout {
        static let tipVisibleHeight: CGFloat = 267
        /// `.full` 상태에서 safeArea top 으로부터 띄울 거리. 주소 버튼(48) + 필터 콜렉션(60) 과 일치해야 한다.
        static let fullTopInset: CGFloat = 95
    }

    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState
    let collapsedVisibleHeight: CGFloat
    let anchors: [FloatingPanelState: any FloatingPanelLayoutAnchoring]

    init(
        initialState: FloatingPanelState = .tip,
        collapsedVisibleHeight: CGFloat = HomeListView.Layout.collapsedVisibleHeight(hasTabs: false)
    ) {
        self.initialState = initialState
        self.collapsedVisibleHeight = collapsedVisibleHeight
        self.anchors = [
            .full: FloatingPanelLayoutAnchor(
                absoluteInset: Layout.fullTopInset,
                edge: .top,
                referenceGuide: .safeArea
            ),
            .tip: FloatingPanelLayoutAnchor(
                absoluteInset: Layout.tipVisibleHeight,
                edge: .bottom,
                referenceGuide: .safeArea
            ),
            .collapsed: FloatingPanelLayoutAnchor(
                absoluteInset: collapsedVisibleHeight,
                edge: .bottom,
                referenceGuide: .safeArea
            )
        ]
    }
}
