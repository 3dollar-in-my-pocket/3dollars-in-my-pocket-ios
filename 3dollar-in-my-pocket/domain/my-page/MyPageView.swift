import UIKit

final class MyPageView: BaseView {
    
    private let scrollView = UIScrollView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.gray100()
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
        $0.text = "마이 페이지"
    }
    
    let settingButton = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_setting"), for: .normal)
    }
    
    private let bgCloud = UIImageView().then {
        $0.image = R.image.bg_cloud_my_page()
        $0.alpha = 0.1
    }
    
    private let bedgeImage = UIImageView().then {
        $0.backgroundColor = UIColor(r: 196, g: 196, b: 196)
        $0.layer.cornerRadius = 60
    }
    
    private let myTitleLabel = TitleLabel()
    
    private let nicknameLabel = UILabel().then {
        $0.font = .bold(size: 30)
        $0.textAlignment = .center
        $0.textColor = .white
        $0.text = "마포구 몽키스패너"
    }
    
    let storeCountButton = CountButton(type: .store)
    
    let reviewCountButton = CountButton(type: .review)
    
    let titleCountButton = CountButton(type: .title)
    
    private let visitBedgeImage = UIImageView().then {
        $0.image = R.image.ic_bedge()
    }
    
    private let visitLabel = UILabel().then {
        $0.text = "방문 인증"
        $0.textColor = .white
        $0.font = .bold(size: 12)
    }
    
    private let visitHistoryButton = UIButton().then {
        $0.setTitle("최근 내가 들린 가게는?", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .regular(size: 24)
    }
    
    private let visitHistoryCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        $0.backgroundColor = .clear
    }
    
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
        self.containerView.addSubViews([
            self.bgCloud,
            self.bedgeImage,
            self.myTitleLabel,
            self.nicknameLabel,
            self.storeCountButton,
            self.reviewCountButton,
            self.titleCountButton,
            self.visitBedgeImage,
            self.visitLabel,
            self.visitHistoryButton,
            self.visitHistoryCollectionView
        ])
        self.scrollView.addSubview(self.containerView)
        self.addSubViews([
            self.titleLabel,
            self.settingButton,
            self.scrollView
        ])
        self.myTitleLabel.bind(title: "붕어빵 챌린저")
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(23)
        }
        
        self.settingButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(24)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(23)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        self.bgCloud.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(154)
        }
        
        self.bedgeImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.bgCloud).offset(11)
            make.width.equalTo(120)
            make.height.equalTo(120)
        }
        
        self.myTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.bedgeImage.snp.bottom).offset(20)
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
        
        self.titleCountButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-36)
            make.centerY.equalTo(self.storeCountButton)
            make.size.equalTo(CountButton.size)
        }
        
        self.visitBedgeImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.storeCountButton.snp.bottom).offset(60)
            make.width.height.equalTo(16)
        }
        
        self.visitLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.visitBedgeImage)
            make.left.equalTo(self.visitBedgeImage.snp.right).offset(4)
        }
        
        self.visitHistoryButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.visitBedgeImage.snp.bottom).offset(12)
        }
        
        self.visitHistoryCollectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.visitHistoryButton.snp.bottom).offset(23)
            make.height.equalTo(112)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(self.scrollView)
            make.top.equalTo(self.bgCloud).priority(.high)
            make.bottom.equalTo(self.visitHistoryCollectionView).priority(.high)
        }
    }
    
    func bind(user: User) {
        self.nicknameLabel.text = user.name
    }
    
//    func setStore(count: Int) {
//        self.registerEmptyBg.isHidden = count != 0
//        self.registerEmptyImage.isHidden = count != 0
//
//        if count == 0 {
//            self.registerLabel.text = "my_page_registered_store_empty".localized
//        } else {
//            self.registerLabel.text = "my_page_registered_store".localized
//            self.registerCountLabel.text = "\(count)개"
//        }
//    }
//
//    func setReview(count: Int) {
//        if count == 0 {
//            self.reviewLabel.text = "my_page_registered_review_empty".localized
//        } else {
//            self.reviewLabel.text = "my_page_registered_review".localized
//            self.reviewCountLabel.text = "\(count)개"
//        }
//    }
}
