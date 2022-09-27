import UIKit

import Base
import RxSwift
import RxCocoa

final class StoreDetailHeaderView: UICollectionReusableView {
    static let registerId = "\(StoreDetailHeaderView.self)"
    static let height: CGFloat = 72
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .semiBold(size: 18)
    }
    
    private let rightLabel = UILabel().then {
        $0.textColor = R.color.gray30()
        $0.font = .semiBold(size: 12)
    }
    
    let rightButton = UIButton().then {
        $0.setTitleColor(R.color.red(), for: .normal)
        $0.titleLabel?.font = .bold(size: 12)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = R.color.red()?.withAlphaComponent(0.2)
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstratins()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: StoreDetailHeaderType, updatedAt: String?) {
        self.titleLabel.text = type.title
        self.rightButton.setTitle(type.rightButtonTitle, for: .normal)
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.rightLabel,
            self.rightButton
        ])
    }
    
    private func bindConstratins() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(self.rightButton)
        }
        
        self.rightLabel.snp.makeConstraints { make in
          make.centerY.equalTo(self.titleLabel)
          make.left.equalTo(self.titleLabel.snp.right).offset(8)
        }
        
        self.rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(32)
        }
    }
}
