import UIKit

import RxSwift

class BaseTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    /// adSubviews와 화면의 기본 속성을 설정합니다.
    func setup() { }
    
    /// Autolayout설정을 진행합니다.
    func bindConstraints() { }
}
