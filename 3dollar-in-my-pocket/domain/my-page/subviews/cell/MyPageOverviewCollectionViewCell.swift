import UIKit

final class MyPageOverviewCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(MyPageOverviewCollectionViewCell.self)"
    static let height: CGFloat = 390
    
    private let containerBackgroundView = UIView().then {
        $0.backgroundColor = R.color.gray95()
        $0.layer.cornerRadius = 10
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    private let bgCloud = UIImageView().then {
        $0.image = R.image.bg_cloud_my_page()
    }
    
    let medalImageButton = UIButton()
    
    private let myTitleLabel = TitleLabel(type: .big)
    
    private let nicknameLabel = UILabel().then {
        $0.font = .bold(size: 30)
        $0.textAlignment = .center
        $0.textColor = .white
    }
    
    let storeCountButton = CountButton(type: .store)
    
    let reviewCountButton = CountButton(type: .review)
    
    let medalCountButton = CountButton(type: .title)
    
    override func setup() {
        self.addSubViews([
            self.containerBackgroundView,
            self.bgCloud,
            self.medalImageButton,
            self.myTitleLabel,
            self.nicknameLabel,
            self.storeCountButton,
            self.reviewCountButton,
            self.medalCountButton
        ])
    }
    
    override func bindConstraints() {
        self.containerBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.storeCountButton).offset(32)
        }
        
        self.bgCloud.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(154)
        }
        
        self.medalImageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.bgCloud).offset(11)
            make.width.equalTo(120)
            make.height.equalTo(120)
        }
        
        self.myTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.medalImageButton.snp.bottom).offset(20)
        }
        
        self.nicknameLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.myTitleLabel.snp.bottom).offset(10)
        }
        
        self.storeCountButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(36)
            make.top.equalTo(self.nicknameLabel.snp.bottom).offset(24)
            make.size.equalTo(CountButton.size)
        }
        
        self.reviewCountButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.storeCountButton)
            make.size.equalTo(CountButton.size)
        }
        
        self.medalCountButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-36)
            make.centerY.equalTo(self.storeCountButton)
            make.size.equalTo(CountButton.size)
        }
    }
    
    func bind(user: User) {
        self.nicknameLabel.text = user.name
        self.medalImageButton.setImage(urlString: user.medal.iconUrl, state: .normal)
        self.myTitleLabel.bind(title: user.medal.name)
        self.storeCountButton.bind(count: user.activity.storesCount)
        self.reviewCountButton.bind(count: user.activity.reviewsCount)
        self.medalCountButton.bind(count: user.activity.medalsCounts)
    }
}
