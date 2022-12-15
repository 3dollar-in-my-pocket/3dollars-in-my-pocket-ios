import UIKit

import RxSwift
import RxCocoa

final class MyPageSectionHeaderView: BaseCollectionReusableView {
    static let registerId = "\(MyPageSectionHeaderView.self)"
    static let height: CGFloat = 115
    
    private let iconView = UIImageView().then {
        $0.tintColor = R.color.gray20()
    }
    
    private let iconLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = R.color.gray20()
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .white
    }
    
    fileprivate let moreButton = UIButton().then {
        $0.setTitle("my_page_more".localized, for: .normal)
        $0.layer.cornerRadius = 15
        $0.backgroundColor = R.color.gray80()
        $0.titleLabel?.font = .bold(size: 12)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.contentEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
        self.addSubViews([
            self.iconView,
            self.iconLabel,
            self.titleLabel,
            self.moreButton
        ])
    }
    
    override func bindConstraints() {
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(36)
            make.width.equalTo(16)
            make.height.equalTo(16)
        }
        
        self.iconLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.iconView)
            make.left.equalTo(self.iconView.snp.right).offset(6)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.iconView)
            make.top.equalTo(self.iconView.snp.bottom).offset(12)
        }
        
        self.moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(self.titleLabel)
            make.height.equalTo(30)
        }
    }
    
    func bind(type: MyPageSectionType) {
        self.iconView.image = type.icon
        self.iconLabel.text = type.iconLabel
        self.titleLabel.text = type.title
    }
}

extension Reactive where Base: MyPageSectionHeaderView {
    var tapMoreButton: ControlEvent<Void> {
        return base.moreButton.rx.tap
    }
}
