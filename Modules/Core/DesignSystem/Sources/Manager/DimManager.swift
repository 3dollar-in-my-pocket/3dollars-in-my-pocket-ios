import UIKit

public final class DimManager {
    public static let shared = DimManager()
    
    private let dimView = UIView(frame: UIScreen.main.bounds)
    
    /// dimView 노출 여부 함수. targetView는 dimView가 추가될 뷰입니다. 없다면 최상위뷰에 추가됩니다.
    public func showDim(targetView: UIView) {
        targetView.addSubview(self.dimView)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.dimView.backgroundColor = DesignSystemAsset.Colors.systemBlack.color.withAlphaComponent(0.8)
        }
    }
    
    public func hideDim() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.dimView.backgroundColor = .clear
        } completion: { [weak self] _ in
            self?.dimView.removeFromSuperview()
        }
    }
}
