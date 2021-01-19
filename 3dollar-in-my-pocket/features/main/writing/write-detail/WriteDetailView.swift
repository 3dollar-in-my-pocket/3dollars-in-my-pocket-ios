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
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor(r: 244, g: 244, b: 244).cgColor
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
  
  let roadRadioButton = UIButton().then {
    $0.setTitle("write_store_type_road".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_radio_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_radio_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let storeRadioButton = UIButton().then {
    $0.setTitle("write_store_type_store".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_radio_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_radio_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let convenienceStoreRadioButton = UIButton().then {
    $0.setTitle("write_store_type_convenience_store".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_radio_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_radio_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
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
  
  let cashCheckButton = UIButton().then {
    $0.setTitle("write_store_payment_cash".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_check_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_check_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let cardCheckButton = UIButton().then {
    $0.setTitle("write_store_payment_card".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_check_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_check_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let transferCheckButton = UIButton().then {
    $0.setTitle("write_store_payment_transfer".localized, for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.setTitleColor(.black, for: .normal)
    $0.setImage(UIImage(named: "ic_check_off"), for: .normal)
    $0.setImage(UIImage(named: "ic_check_on"), for: .selected)
    $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
  }
  
  let generateLabel = UILabel().then {
    $0.text = "write_store_generate".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 14)
    $0.textColor = .black
  }
  
  let generateOptionLabel = UILabel().then {
    $0.text = "write_store_option".localized
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
  }
  
  let dayStackView = DayStackView()
  
  let menuLabel = UILabel().then {
    $0.text = "write_store_menu".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
  }
  
  let menuOptionLabel = UILabel().then {
    $0.text = "write_store_option".localized
    $0.textColor = UIColor(r: 183, g: 183, b: 183)
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
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
    layout.itemSize = CGSize(width: 52, height: 70)
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
  }
  
  let menuTableView = UITableView().then {
    $0.backgroundColor = .white
    $0.isScrollEnabled = false
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
  }
  
  let registerBtnBg = UIView().then {
    $0.layer.cornerRadius = 37
    
    let shadowLayer = CAShapeLayer()
    
    shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 232, height: 72), cornerRadius: 37).cgPath
    shadowLayer.fillColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.6).cgColor
    shadowLayer.shadowColor = UIColor.black.cgColor
    shadowLayer.shadowPath = nil
    shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
    shadowLayer.shadowOpacity = 0.3
    shadowLayer.shadowRadius = 10
    $0.layer.insertSublayer(shadowLayer, at: 0)
  }
  
  let registerBtn = UIButton().then {
    $0.setTitle("현재 위치로 등록하기", for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    $0.isEnabled = false
    $0.setBackgroundColor(UIColor.init(r: 200, g: 200, b: 200), for: .disabled)
    $0.setBackgroundColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
    $0.layer.masksToBounds = true
  }
  
  
  override func setup() {
    backgroundColor = UIColor(r: 250, g: 250, b: 250)
    scrollView.delegate = self
    addGestureRecognizer(bgTap)
    containerView.addSubViews(
      locationLabel, modifyLocationButton, locationContainer, locationFieldContainer,
      locationValueLabel, storeInfoLabel, storeInfoContainer, storeNameLabel,
      storeNameContainer, storeNameField, storeTypeLabel, storeTypeOptionLabel,
      roadRadioButton, storeRadioButton, convenienceStoreRadioButton, paymentTypeLabel,
      paymentTypeOptionLabel, paymentTypeMultiLabel, cashCheckButton, cardCheckButton,
      transferCheckButton, generateLabel, generateOptionLabel, dayStackView,
      menuLabel, menuOptionLabel, deleteAllButton, categoryContainer,
      categoryCollectionView, menuTableView
    )
    
    scrollView.addSubview(containerView)
    addSubViews(scrollView, navigationView, backButton, titleLabel, registerBtnBg, registerBtn)
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
    
    self.roadRadioButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeTypeLabel.snp.bottom).offset(17)
      make.height.equalTo(20)
    }
    
    self.storeRadioButton.snp.makeConstraints { make in
      make.left.equalTo(self.roadRadioButton.snp.right).offset(31)
      make.centerY.equalTo(self.roadRadioButton)
    }
    
    self.convenienceStoreRadioButton.snp.makeConstraints { make in
      make.left.equalTo(self.storeRadioButton.snp.right).offset(31)
      make.centerY.equalTo(self.storeRadioButton)
    }
    
    self.paymentTypeLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.roadRadioButton.snp.bottom).offset(40)
    }

    self.paymentTypeOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.paymentTypeLabel.snp.right).offset(6)
      make.centerY.equalTo(self.paymentTypeLabel)
    }

    self.paymentTypeMultiLabel.snp.makeConstraints { make in
      make.left.equalTo(self.paymentTypeOptionLabel.snp.right).offset(7)
      make.centerY.equalTo(self.paymentTypeLabel)
    }

    self.cashCheckButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.paymentTypeLabel.snp.bottom).offset(16)
    }

    self.cardCheckButton.snp.makeConstraints { make in
      make.left.equalTo(self.cashCheckButton.snp.right).offset(43)
      make.centerY.equalTo(self.cashCheckButton)
    }
    
    self.transferCheckButton.snp.makeConstraints { make in
      make.left.equalTo(self.cardCheckButton.snp.right).offset(36)
      make.centerY.equalTo(self.cashCheckButton)
    }
    
    self.registerBtnBg.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.equalTo(232)
      make.height.equalTo(72)
      make.bottom.equalToSuperview().offset(-32)
    }
    
    self.registerBtn.snp.makeConstraints { (make) in
      make.left.equalTo(registerBtnBg.snp.left).offset(8)
      make.right.equalTo(registerBtnBg.snp.right).offset(-8)
      make.top.equalTo(registerBtnBg.snp.top).offset(8)
      make.bottom.equalTo(registerBtnBg.snp.bottom).offset(-8)
    }
    
    self.generateLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.cashCheckButton.snp.bottom).offset(40)
    }
    
    self.generateOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.generateLabel.snp.right).offset(6)
      make.centerY.equalTo(self.generateLabel)
    }
    
    self.dayStackView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.generateLabel.snp.bottom).offset(13)
    }
    
    self.menuLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(self.storeInfoContainer.snp.bottom).offset(40)
    }
    
    self.menuOptionLabel.snp.makeConstraints { make in
      make.left.equalTo(self.menuLabel.snp.right).offset(4)
      make.centerY.equalTo(self.menuLabel)
    }
    
    self.deleteAllButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.menuLabel)
    }
    
    self.categoryContainer.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.menuLabel.snp.bottom).offset(16)
      make.bottom.equalTo(self.categoryCollectionView).offset(24)
    }
    
    self.categoryCollectionView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.top.equalTo(self.categoryContainer).offset(24)
      make.height.equalTo(72)
    }
    
    self.menuTableView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalTo(self.categoryContainer.snp.bottom).offset(10)
      make.height.equalTo(0)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.refreshMenuTableViewHeight()
    registerBtn.layer.cornerRadius = registerBtn.frame.height / 2
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
  
  func refreshMenuTableViewHeight(section: Int = 0) {
    if section == -1 {
      menuTableView.snp.updateConstraints { make in
        make.height.equalTo(0)
      }
    } else {
      menuTableView.snp.updateConstraints { make in
        make.height.equalTo(self.menuTableView.contentSize.height + 20)
      }
    }
  }
//
//  func tapCategoryBtn(index: Int) {
//    let buttons = [bungeoppangBtn, takoyakiBtn, gyeranppangBtn, hotteokBtn]
//
//    for buttonIndex in buttons.indices {
//      buttons[buttonIndex].isSelected = (buttonIndex == index)
//    }
//  }
//
//  func setFieldEmptyMode(isEmpty: Bool) {
//    if isEmpty {
//      nameField.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
//    } else {
//      nameField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
//    }
//  }
  
  func hideRegisterBtn() {
    if registerBtnBg.alpha != 0 {
      let originalBgTransform = self.registerBtnBg.transform
      let originalBtnTransform = self.registerBtn.transform
      
      UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
        self?.registerBtnBg.transform = originalBgTransform.translatedBy(x: 0.0, y: 90)
        self?.registerBtnBg.alpha = 0
        
        self?.registerBtn.transform = originalBtnTransform.translatedBy(x: 0.0, y: 90)
        self?.registerBtn.alpha = 0
      })
    }
  }
  
  func showRegisterBtn() {
    if registerBtnBg.alpha != 1 {
      let originalBgTransform = self.registerBtnBg.transform
      let originalBtnTransform = self.registerBtn.transform
      
      UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
        self?.registerBtnBg.transform = originalBgTransform.translatedBy(x: 0.0, y: -90)
        self?.registerBtnBg.alpha = 1
        
        self?.registerBtn.transform = originalBtnTransform.translatedBy(x: 0.0, y: -90)
        self?.registerBtn.alpha = 1
      })
    }
  }
}

extension WriteDetailView: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.hideRegisterBtn()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      self.showRegisterBtn()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    self.showRegisterBtn()
  }
}
