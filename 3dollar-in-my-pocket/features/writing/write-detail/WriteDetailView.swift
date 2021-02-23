import UIKit

class WriteDetailView: BaseView {
  
  let bgTap = UITapGestureRecognizer().then {
    $0.cancelsTouchesInView = false
  }
  
  let navigationView = UIView().then {
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    
    $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.04
    $0.backgroundColor = .white
  }
  
  let backButton = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "write_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = .black
  }
  
  let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 98, right: 0)
  }
  
  let containerView = UIView()
  
  let locationLabel = UILabel().then {
    $0.text = "write_location".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
    $0.textColor = .black
  }
  
  let modifyLocationButton = UIButton().then {
    $0.setTitle("write_modify_location".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.setTitleColor(UIColor(r: 255, g: 92, b: 67), for: .normal)
  }
  
  let locationContainer = UIView().then {
    $0.backgroundColor = .white
  }
  
  let locationFieldContainer = UIView().then {
    $0.backgroundColor = UIColor(r: 244, g: 244, b: 244)
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 208, g: 208, b: 208).cgColor
  }
  
  let locationValueLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.text = "주소주소"
  }
  
  let storeInfoLabel = UILabel().then {
    $0.text = "write_store_info".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
    $0.textColor = .black
  }
  
  let storeInfoContainer = UIView().then {
    $0.backgroundColor = .white
  }
  
  let storeNameLabel = UILabel().then {
    $0.text = "write_store_info_name".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.textColor = .black
  }
  
  let storeNameContainer = UIView().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 244, g: 244, b: 244).cgColor
  }
  
  let storeNameField = UITextField().then {
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.placeholder = "write_store_info_name_placeholder".localized
  }
  
  let storeTypeLabel = UILabel().then {
    $0.text = "write_store_type".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
    $0.textColor = .black
  }
  
  let storeTypeOptionLabel = UILabel().then {
    $0.text = "write_store_option".localized
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let storeTypeStackView = WriteDetailTypeStackView()
  
  let paymentTypeLabel = UILabel().then {
    $0.text = "write_store_payment_type".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.textColor = .black
  }
  
  let paymentTypeOptionLabel = UILabel().then {
    $0.text = "write_store_option".localized
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let paymentTypeMultiLabel = UILabel().then {
    $0.text = "write_store_payment_multi".localized
    $0.textColor = UIColor(r: 255, g: 161, b: 170)
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
  }
  
  let paymentStackView = WriteDetailPaymentStackView()
  
  let daysLabel = UILabel().then {
    $0.text = "write_store_days".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.textColor = .black
  }
  
  let daysOptionLabel = UILabel().then {
    $0.text = "write_store_option".localized
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let dayStackView = DayStackInputView()
  
  let categoryLabel = UILabel().then {
    $0.text = "write_store_category".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
  }
  
  let deleteAllButton = UIButton().then {
    $0.setTitle("write_store_delete_all_menu".localized, for: .normal)
    $0.setTitleColor(UIColor(r: 255, g: 92, b: 67), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
  }
  
  let categoryContainer = UIView().then {
    $0.backgroundColor = .white
  }
  
  let categoryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = LeftAlignedCollectionViewFlowLayout()
    
    layout.minimumInteritemSpacing = 16 * RatioUtils.widthRatio
    layout.minimumLineSpacing = 20
    layout.estimatedItemSize = CGSize(width: 52, height: 75)
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
  }
  
  let menuLabel = UILabel().then {
    $0.text = "write_store_menu".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
    $0.isHidden = true
  }
  
  let menuOptionLabel = UILabel().then {
    $0.text = "write_store_option".localized
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
    $0.isHidden = true
  }
  
  let menuTableView = UITableView().then {
    $0.backgroundColor = .white
    $0.isScrollEnabled = false
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
    $0.sectionFooterHeight = 20
  }
  
  let registerButtonBg = UIView().then {
    $0.layer.cornerRadius = 37
    
    let shadowLayer = CAShapeLayer()
    
    shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 232, height: 64), cornerRadius: 37).cgPath
    shadowLayer.fillColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.6).cgColor
    shadowLayer.shadowColor = UIColor.black.cgColor
    shadowLayer.shadowPath = nil
    shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 10
    $0.layer.insertSublayer(shadowLayer, at: 0)
  }
  
  let registerButton = UIButton().then {
    $0.setTitle("write_store_register_button".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.isEnabled = false
    $0.setBackgroundColor(UIColor.init(r: 208, g: 208, b: 208), for: .disabled)
    $0.setBackgroundColor(UIColor.init(r: 255, g: 92, b: 67), for: .normal)
    $0.layer.masksToBounds = true
  }
  
  
  override func setup() {
    backgroundColor = UIColor(r: 250, g: 250, b: 250)
    addGestureRecognizer(bgTap)
    containerView.addSubViews(
      locationLabel, modifyLocationButton, locationContainer, locationFieldContainer,
      locationValueLabel, storeInfoLabel, storeInfoContainer, storeNameLabel,
      storeNameContainer, storeNameField, storeTypeLabel, storeTypeOptionLabel,
      storeTypeStackView, paymentTypeLabel, paymentTypeOptionLabel,
      paymentTypeMultiLabel, paymentStackView, daysLabel,
      daysOptionLabel, dayStackView, categoryLabel, deleteAllButton,
      categoryContainer, categoryCollectionView, menuLabel, menuOptionLabel,
      menuTableView
    )
    
    scrollView.addSubview(containerView)
    addSubViews(scrollView, navigationView, backButton, titleLabel, registerButtonBg, registerButton)
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { (make) in
      make.left.right.top.equalToSuperview()
      make.bottom.equalTo(self.safeAreaLayoutGuide.snp.top).offset(60)
    }
    
    self.backButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.navigationView).offset(-22)
    }
    
    self.scrollView.snp.makeConstraints { (make) in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(self.navigationView.snp.bottom)
    }
    
    self.containerView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
      make.width.equalTo(frame.width)
      make.top.equalToSuperview()
      make.bottom.equalTo(self.menuTableView)
    }
    
    self.locationLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(40)
    }
    
    self.modifyLocationButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.locationLabel)
    }
    
    self.locationContainer.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.locationLabel.snp.bottom).offset(16)
      make.bottom.equalTo(self.locationFieldContainer).offset(24)
    }
    
    self.locationFieldContainer.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.locationContainer).offset(24)
      make.bottom.equalTo(self.locationValueLabel).offset(13)
    }
    
    self.locationValueLabel.snp.makeConstraints { make in
      make.left.equalTo(self.locationFieldContainer).offset(16)
      make.right.equalTo(self.locationFieldContainer).offset(-16)
      make.top.equalTo(self.locationFieldContainer).offset(16)
    }
    
    self.storeInfoLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.locationContainer.snp.bottom).offset(33)
    }
    
    self.storeInfoContainer.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.storeInfoLabel.snp.bottom).offset(16)
      make.bottom.equalTo(self.dayStackView).offset(24)
    }
    
    self.storeNameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeInfoContainer).offset(30)
    }
    
    self.storeNameContainer.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.storeNameLabel.snp.bottom).offset(10)
      make.bottom.equalTo(self.storeNameField).offset(15)
    }
    
    self.storeNameField.snp.makeConstraints { make in
      make.left.equalTo(self.storeNameContainer).offset(16)
      make.top.equalTo(self.storeNameContainer).offset(16)
      make.right.equalTo(self.storeNameContainer).offset(-16)
    }
    
    self.storeTypeLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeNameContainer.snp.bottom).offset(40)
    }
    
    self.storeTypeOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.storeTypeLabel.snp.right).offset(6)
      make.centerY.equalTo(self.storeTypeLabel)
    }
    
    self.storeTypeStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeTypeLabel.snp.bottom).offset(17)
    }
    
    self.paymentTypeLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeTypeStackView.snp.bottom).offset(40)
    }

    self.paymentTypeOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.paymentTypeLabel.snp.right).offset(6)
      make.centerY.equalTo(self.paymentTypeLabel)
    }

    self.paymentTypeMultiLabel.snp.makeConstraints { make in
      make.left.equalTo(self.paymentTypeOptionLabel.snp.right).offset(7)
      make.centerY.equalTo(self.paymentTypeLabel)
    }
    
    self.paymentStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.paymentTypeLabel.snp.bottom).offset(16)
    }
    
    self.registerButtonBg.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.equalTo(232)
      make.height.equalTo(64)
      make.bottom.equalToSuperview().offset(-32)
    }
    
    self.registerButton.snp.makeConstraints { (make) in
      make.left.equalTo(registerButtonBg.snp.left).offset(8)
      make.right.equalTo(registerButtonBg.snp.right).offset(-8)
      make.top.equalTo(registerButtonBg.snp.top).offset(8)
      make.bottom.equalTo(registerButtonBg.snp.bottom).offset(-8)
    }
    
    self.daysLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.paymentStackView.snp.bottom).offset(40)
    }
    
    self.daysOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.daysLabel.snp.right).offset(6)
      make.centerY.equalTo(self.daysLabel)
    }
    
    self.dayStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.daysLabel.snp.bottom).offset(13)
    }
    
    self.categoryLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeInfoContainer.snp.bottom).offset(40)
    }
    
    self.deleteAllButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.categoryLabel)
    }
    
    self.categoryContainer.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.categoryLabel.snp.bottom).offset(16)
      make.bottom.equalTo(self.categoryCollectionView).offset(24)
    }
    
    self.categoryCollectionView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.categoryContainer).offset(24)
      make.height.equalTo(72)
    }
    
    self.menuLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.categoryContainer.snp.bottom).offset(20)
    }
    
    self.menuOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.menuLabel.snp.right).offset(4)
      make.centerY.equalTo(self.menuLabel)
    }
    
    self.menuTableView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.menuLabel.snp.bottom).offset(12)
      make.height.equalTo(0)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.refreshMenuTableViewHeight()
    registerButton.layer.cornerRadius = registerButton.frame.height / 2
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    self.refreshMenuTableViewHeight()
  }
  
  private func setupNavigationBar() {
    navigationView.layer.cornerRadius = 16
    navigationView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    
    navigationView.layer.shadowOffset = CGSize(width: 8, height: 8)
    navigationView.layer.shadowColor = UIColor.black.cgColor
    navigationView.layer.shadowOpacity = 0.08
  }
  
  func refreshCategoryCollectionViewHeight() {
    self.categoryCollectionView.snp.updateConstraints { make in
      make.height.equalTo(self.categoryCollectionView.contentSize.height)
    }
  }
  
  func refreshMenuTableViewHeight() {
    menuTableView.snp.updateConstraints { make in
      make.height.equalTo(self.menuTableView.contentSize.height)
    }
  }
  
  func setStoreNameBorderColoe(isEmpty: Bool) {
    self.storeNameContainer.layer.borderColor = isEmpty ? UIColor(r: 244, g: 244, b: 244).cgColor : UIColor(r: 255, g: 161, b: 170).cgColor
  }
  
  func setMenuHeader(menuSections: [MenuSection]) {
    self.menuLabel.isHidden = menuSections.isEmpty
    self.menuOptionLabel.isHidden = menuSections.isEmpty
  }
  
  func hideRegisterButton() {
    if registerButtonBg.alpha != 0 {
      let originalBgTransform = self.registerButtonBg.transform
      let originalBtnTransform = self.registerButton.transform
      
      UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
        self?.registerButtonBg.transform = originalBgTransform.translatedBy(x: 0.0, y: 90)
        self?.registerButtonBg.alpha = 0
        
        self?.registerButton.transform = originalBtnTransform.translatedBy(x: 0.0, y: 90)
        self?.registerButton.alpha = 0
      })
    }
  }
  
  func showRegisterButton() {
    if registerButtonBg.alpha != 1 {
      let originalBgTransform = self.registerButtonBg.transform
      let originalBtnTransform = self.registerButton.transform
      
      UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
        self?.registerButtonBg.transform = originalBgTransform.translatedBy(x: 0.0, y: -90)
        self?.registerButtonBg.alpha = 1
        
        self?.registerButton.transform = originalBtnTransform.translatedBy(x: 0.0, y: -90)
        self?.registerButton.alpha = 1
      })
    }
  }
}
