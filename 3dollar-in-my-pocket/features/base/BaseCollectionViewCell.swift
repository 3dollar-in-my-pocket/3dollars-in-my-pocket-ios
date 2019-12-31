import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        bindConstraints()
    }
    
    func setup() { }
    
    
    func bindConstraints() { }
}
