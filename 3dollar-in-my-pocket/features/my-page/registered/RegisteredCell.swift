import UIKit

class RegisteredCell: BaseTableViewCell {
    
    static let registerId = "\(RegisteredCell.self)"
    
    
    let background = UIView().then {
        $0.backgroundColor = UIColor.init(r: 74, g: 74, b: 74)
        $0.layer.cornerRadius = 16
    }
    
    let categoryImage = UIImageView().then {
        $0.image = UIImage.init(named: "img_card_bungeoppang_on")
    }
    
    let titleLabel = UILabel().then {
        $0.text = "강남역 2번출구 앞"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textColor = .white
    }
    
    let rankingView = RankingView()
    
    override func setup() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubViews(background, categoryImage, titleLabel, rankingView)
    }
    
    override func bindConstraints() {
        background.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
        
        categoryImage.snp.makeConstraints { (make) in
            make.top.equalTo(background.snp.top).offset(20)
            make.bottom.equalTo(background.snp.bottom).offset(-20)
            make.left.equalTo(background.snp.left).offset(16)
            make.width.equalTo(80)
            make.height.equalTo(56)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(categoryImage.snp.top)
            make.left.equalTo(categoryImage.snp.right).offset(16)
            make.right.equalTo(background).offset(-10)
        }
        
        rankingView.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
    }
    
    func bind(store: Store) {
        switch store.category {
        case .BUNGEOPPANG:
            categoryImage.image = UIImage.init(named: "img_mypage_bungeoppang")
        case .GYERANPPANG:
            categoryImage.image = UIImage.init(named: "img_mypage_gyeranppang")
        case.HOTTEOK:
            categoryImage.image = UIImage.init(named: "img_mypage_hotteok")
        case.TAKOYAKI:
            categoryImage.image = UIImage.init(named: "img_mypage_takoyaki")
        }
        titleLabel.text = store.storeName
        rankingView.setRank(rank: store.rating)
    }
}
