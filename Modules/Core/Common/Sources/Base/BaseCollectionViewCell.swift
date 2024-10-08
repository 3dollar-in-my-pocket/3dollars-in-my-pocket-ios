import UIKit
import Combine

open class BaseCollectionViewCell: UICollectionViewCell {
    public var cancellables = Set<AnyCancellable>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellables = Set<AnyCancellable>()
    }
    
    /// adSubviews와 화면의 기본 속성을 설정합니다.
    open func setup() { }
    
    /// Autolayout설정을 진행합니다.
    open func bindConstraints() { }
}
