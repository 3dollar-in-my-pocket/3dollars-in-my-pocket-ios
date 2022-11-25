import UIKit

import RxSwift
import RxCocoa

final class StoreDetailHeaderView: UICollectionReusableView {
    static let registerId = "\(StoreDetailHeaderView.self)"
    static let height: CGFloat = 72
    var disposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .semiBold(size: 18)
    }
    
    private let subtitleLabel = UILabel().then {
        $0.textColor = R.color.black()
        $0.font = .medium(size: 18)
    }
    
    private let descriptionLabel = UILabel().then {
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstratins()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(type: StoreDetailHeaderType, rightText: String?) {
        self.titleLabel.text = type.title
        
        self.rightButton.setTitle(type.rightButtonTitle, for: .normal)
        switch type {
        case .info:
            self.descriptionLabel.text = rightText
            self.descriptionLabel.isHidden = false
            self.subtitleLabel.isHidden = true
            
        case .photo, .review:
            self.subtitleLabel.text = rightText
            self.descriptionLabel.isHidden = true
            self.subtitleLabel.isHidden = false
        }
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.descriptionLabel,
            self.subtitleLabel,
            self.rightButton
        ])
    }
    
    private func bindConstratins() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(self.rightButton)
        }
        
        self.subtitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel.snp.right).offset(5)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
          make.centerY.equalTo(self.titleLabel)
          make.left.equalTo(self.titleLabel.snp.right).offset(8)
        }
        
        self.rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview().offset(32)
        }
    }
}
