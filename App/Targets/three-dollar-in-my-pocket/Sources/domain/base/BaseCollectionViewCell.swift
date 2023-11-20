import UIKit
import Combine

import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
    var disposeBag = DisposeBag()
    var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
        cancellables = Set<AnyCancellable>()
    }
    
    /// adSubviews와 화면의 기본 속성을 설정합니다.
    func setup() { }
    
    /// Autolayout설정을 진행합니다.
    func bindConstraints() { }
}
