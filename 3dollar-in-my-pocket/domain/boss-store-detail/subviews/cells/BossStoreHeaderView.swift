import UIKit

import RxSwift
import RxCocoa

final class BossStoreHeaderView: UICollectionReusableView {
    static let registerId = "\(BossStoreHeaderView.self)"
    static let height: CGFloat = 73
    
    var disposeBag = DisposeBag()
    
    let titleLabel = UILabel().then {
        $0.font = .extraBold(size: 18)
        $0.textColor = R.color.black()
    }
    
    let rightButton = UIButton().then {
        $0.setTitleColor(R.color.green(), for: .normal)
        $0.titleLabel?.font = .bold(size: 12)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = UIColor(r: 0, g: 198, b: 103, a: 0.13)
        $0.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubViews([
            self.titleLabel,
            self.rightButton
        ])
    }
    
    private func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(37)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        self.rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.titleLabel)
        }
    }
}

extension Reactive where Base: BossStoreHeaderView {
    var tapRightButton: ControlEvent<Void> {
        return base.rightButton.rx.tap
    }
}
