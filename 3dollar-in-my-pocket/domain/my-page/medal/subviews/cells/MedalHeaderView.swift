import UIKit

import RxSwift

final class MedalHeaderView: UICollectionReusableView {
    static let registerId = "\(MedalHeaderView.self)"
    static let size = CGSize(width: UIScreen.main.bounds.width - 48, height: 73)
    
    var disposeBag = DisposeBag()
    
    private let dividorView = UIView().then {
        $0.backgroundColor = R.color.gray80()
        $0.layer.cornerRadius = 0.5
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = .white
    }
    
    let infoButton = UIButton().then {
        $0.setImage(R.image.ic_info(), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        self.bindConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() { 
        self.backgroundColor = .clear
        self.addSubViews([
            self.dividorView,
            self.titleLabel,
            self.infoButton
        ])
    }
    
    private func bindConstraints() {
        self.dividorView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(self.dividorView.snp.bottom).offset(15)
            make.bottom.equalToSuperview()
        }
        
        self.infoButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.left.equalTo(self.titleLabel.snp.right).offset(8)
        }
    }
    
    func bind(title: String) {
        self.titleLabel.text = title
    }
}
