import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        bindConstraints()
    }
    
    func setup() { }
    
    func bindConstraints() { }
}
