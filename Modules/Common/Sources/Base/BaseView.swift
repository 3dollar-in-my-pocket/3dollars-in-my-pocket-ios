import UIKit
import Combine

open class BaseView: UIView {
    open var cancellables = Set<AnyCancellable>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// addSubviews와 화면의 기본 속성을 설정합니다.
    open func setup() { }
    
    /// Autolayout설정을 진행합니다.
    open func bindConstraints() { }
}
