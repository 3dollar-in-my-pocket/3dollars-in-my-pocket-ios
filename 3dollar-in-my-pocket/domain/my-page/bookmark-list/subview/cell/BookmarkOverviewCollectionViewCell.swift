import UIKit

final class BookmarkOverviewCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(BookmarkOverviewCollectionViewCell.self)"
    static let height: CGFloat = 256
    
    private let contaienrView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.layer.masksToBounds = true
        $0.backgroundColor = R.color.gray95()
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .white
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.text = "마포구 몽키스패너님의\n즐겨찾기"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .regular(size: 12)
        $0.textColor = R.color.gray50()
        $0.numberOfLines = 0
        $0.text = "제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다 제가 엄선한 가게입니다"
    }
    
    let editButton = UIButton().then {
        $0.setTitle("정보 수정하기", for: .normal)
        $0.backgroundColor = R.color.gray80()
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .bold(size: 12)
        $0.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        $0.layer.cornerRadius = 15
    }
    
    override func setup() {
        self.addSubViews([
            self.contaienrView,
            self.titleLabel,
            self.descriptionLabel,
            self.editButton
        ])
    }
    
    override func bindConstraints() {
        self.contaienrView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.contaienrView).offset(24)
            make.top.equalTo(self.contaienrView).offset(26)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
        }
        
        self.editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(self.contaienrView).offset(-18)
            make.height.equalTo(30)
        }
    }
}
