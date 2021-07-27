import UIKit

class MyPageView: BaseView {
  
  let scrollView = UIScrollView()
  
  let containerView = UIView().then {
    $0.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
  }
  
  let nicknameContainer = UIView().then {
    $0.layer.borderColor = UIColor.init(r: 255, g: 161, b: 170).cgColor
    $0.layer.borderWidth = 2
    $0.layer.cornerRadius = 23
  }
  
  let nicknameLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 16)
    $0.textAlignment = .left
    $0.textColor = UIColor.init(r: 255, g: 161, b: 170)
  }
  
  let settingButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_setting"), for: .normal)
  }
  
  let bgCloud = UIImageView().then {
    $0.image = UIImage.init(named: "bg_cloud_my_page")
    $0.alpha = 0.1
  }
  
  let registerLabel = UILabel().then {
    $0.text = "my_page_registered_store".localized
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
  }
  
  let registerCountLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 24)
  }
  
  let registerTotalButton = UIButton().then {
    $0.setTitle("my_page_total".localized, for: .normal)
    $0.setTitleColor(UIColor.init(r: 255, g: 92, b: 67), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let registerCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 16
    layout.itemSize = CGSize(width: 172, height: 172)
    $0.collectionViewLayout = layout
    $0.showsHorizontalScrollIndicator = false
    $0.backgroundColor = .clear
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 20, right: 196)
  }
  
  let registerEmptyImage = UIImageView().then {
    $0.image = UIImage.init(named: "img_my_page_empty")
    $0.isHidden = true
  }
  
  let registerEmptyBg = UIView().then {
    $0.backgroundColor = UIColor.init(r: 65, g: 65, b: 65)
    $0.layer.cornerRadius = 16
    $0.alpha = 0.4
  }
  
  let reviewLabel = UILabel().then {
    $0.text = "my_page_registered_review".localized
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
  }
  
  let reviewCountLabel = UILabel().then {
    $0.textColor = .white
    $0.font = UIFont(name: "AppleSDGothicNeoEB00", size: 24)
  }
  
  let reviewTotalButton = UIButton().then {
    $0.setTitle("my_page_total".localized, for: .normal)
    $0.setTitleColor(UIColor.init(r: 255, g: 92, b: 67), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let reviewTableView = UITableView().then {
    $0.backgroundColor = .clear
    $0.tableFooterView = UIView()
    $0.separatorStyle = .none
    $0.rowHeight = UITableView.automaticDimension
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
  }
  
  let reviewEmptyImage = UIImageView().then {
    $0.image = UIImage.init(named: "img_my_page_empty")
    $0.isHidden = true
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
    self.containerView.addSubViews(
      bgCloud, nicknameContainer, nicknameLabel, settingButton,
      registerLabel, registerCountLabel, registerTotalButton,
      registerCollectionView, registerEmptyBg, registerEmptyImage,
      reviewLabel, reviewCountLabel, reviewTotalButton, reviewTableView,
      reviewEmptyImage
    )
    self.scrollView.addSubview(containerView)
    self.addSubViews(scrollView)
  }
  
  override func bindConstraints() {
    self.scrollView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide)
    }
    
    self.nicknameContainer.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(safeAreaInsets.top + 35)
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.height.equalTo(46)
    }
    
    self.settingButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.nicknameContainer)
      make.right.equalTo(self.nicknameContainer).offset(-16)
      make.width.height.equalTo(24)
    }
    
    self.nicknameLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.nicknameContainer)
      make.left.equalTo(nicknameContainer).offset(16)
      make.right.equalTo(settingButton.snp.right).offset(-16)
    }
    
    self.bgCloud.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.nicknameContainer.snp.bottom).offset(19)
      make.height.equalTo(135)
    }
    
    self.registerLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.bottom.equalTo(self.bgCloud.snp.bottom)
    }
    
    self.registerCountLabel.snp.makeConstraints { (make) in
      make.left.equalTo(self.registerLabel.snp.right).offset(5)
      make.centerY.equalTo(self.registerLabel).offset(-3)
    }
    
    self.registerTotalButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.registerLabel.snp.centerY)
      make.right.equalToSuperview().offset(-24)
    }
    
    self.registerCollectionView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.registerLabel.snp.bottom).offset(16)
      make.height.equalTo(200)
    }
    
    self.registerEmptyBg.snp.makeConstraints { (make) in
      make.width.height.equalTo(172)
      make.left.equalToSuperview().offset(20)
      make.top.equalTo(self.registerLabel.snp.bottom).offset(12)
    }
    
    self.registerEmptyImage.snp.makeConstraints { (make) in
      make.center.equalTo(self.registerEmptyBg)
      make.width.height.equalTo(112)
    }
    
    self.reviewLabel.snp.makeConstraints { (make) in
      make.left.equalTo(self.registerLabel.snp.left)
      make.top.equalTo(self.registerCollectionView.snp.bottom).offset(10)
    }
    
    self.reviewCountLabel.snp.makeConstraints { (make) in
      make.left.equalTo(self.reviewLabel.snp.right).offset(5)
      make.centerY.equalTo(self.reviewLabel.snp.centerY).offset(-3)
    }
    
    self.reviewTotalButton.snp.makeConstraints { (make) in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.reviewLabel)
    }
    
    self.reviewTableView.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalToSuperview().offset(130)
      make.top.equalTo(self.reviewLabel.snp.bottom).offset(19)
    }
    
    self.reviewEmptyImage.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.reviewLabel.snp.bottom).offset(25)
      make.width.height.equalTo(112 * UIScreen.main.bounds.width / 375)
    }
    
    self.containerView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
      make.width.equalTo(frame.width)
      make.top.equalToSuperview()
      make.height.equalTo(736)
    }
  }
  
  func bind(user: User) {
    self.nicknameLabel.text = user.nickname
  }
  
  func setStore(count: Int) {
    self.registerEmptyBg.isHidden = count != 0
    self.registerEmptyImage.isHidden = count != 0
    
    if count == 0 {
      self.registerLabel.text = "my_page_registered_store_empty".localized
    } else {
      self.registerLabel.text = "my_page_registered_store".localized
      self.registerCountLabel.text = "\(count)개"
    }
  }
  
  func setReview(count: Int) {
    if count == 0 {
      self.reviewLabel.text = "my_page_registered_review_empty".localized
    } else {
      self.reviewLabel.text = "my_page_registered_review".localized
      self.reviewCountLabel.text = "\(count)개"
    }
  }
}
