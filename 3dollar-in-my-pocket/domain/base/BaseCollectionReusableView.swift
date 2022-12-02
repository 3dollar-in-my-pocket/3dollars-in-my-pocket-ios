import UIKit

import RxSwift

class BaseCollectionReusableView: UICollectionReusableView {
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// adSubviews와 화면의 기본 속성을 설정합니다.
    func setup() { }
    
    /// Autolayout설정을 진행합니다.
    func bindConstraints() { }
}
