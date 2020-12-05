import UIKit
import NMapsMap

class ModifyView: BaseView {
  
  let bgTap = UITapGestureRecognizer().then {
    $0.cancelsTouchesInView = false
  }
  
  let navigationBar = UIView().then {
    $0.backgroundColor = .white
  }
  
  let backBtn = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "가게 정보 수정"
    $0.textColor = UIColor.init(r: 51, g: 51, b: 51)
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
  }
  
  let deleteBtn = UIButton().then {
    $0.setTitle("신고", for: .normal)
    $0.setTitleColor(UIColor.init(r: 130, g: 130, b: 130), for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
  }
  
  let mapView = NMFMapView()
  
  let titleContainer = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  let repoterValueLabel = UILabel().then {
    $0.textColor = .black
    $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
    
    let text = "효자동 불효자 님이"
    let attributedText = NSMutableAttributedString(string: text)
    
    attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 24)!, range: (text as NSString).range(of: "효자동 불효자"))
    $0.attributedText = attributedText
  }
  
  let repoterLabel = UILabel().then {
    $0.text = "제보한 가게입니다."
    $0.textColor = .black
    $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
  }
  
  let categoryLabel = UILabel().then {
    $0.text = "붕어빵"
    $0.layer.cornerRadius = 8
    $0.backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
    $0.textColor = UIColor.init(r: 243, g: 162, b: 169)
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    $0.textAlignment = .center
    $0.layer.masksToBounds = true
  }
  
  let nameField = UITextField().then {
    $0.layer.cornerRadius = 8
    $0.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
    $0.layer.borderWidth = 1
    $0.returnKeyType = .done
    $0.text = "강남역 2번출구 앞"
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    $0.textColor = UIColor.init(r: 28, g: 28, b: 28)
    $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
    $0.leftViewMode = .always
    $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
    $0.rightViewMode = .always
  }
  
  let imageLabel = UILabel().then {
    $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
    $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
    
    let text = "총 3개의 사진 제보!"
    let attributedText = NSMutableAttributedString(string: text)
    
    attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 16)!, range: (text as NSString).range(of: "3개"))
    $0.attributedText = attributedText
  }
  
  let imageCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    $0.showsHorizontalScrollIndicator = false
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
  }
  
  let menuLabel = UILabel().then {
    $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
    $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
    
    let text = "총 3개의 메뉴 제보!"
    let attributedText = NSMutableAttributedString(string: text)
    
    attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 16)!, range: (text as NSString).range(of: "3개"))
    $0.attributedText = attributedText
  }
  
  let menuTableView = UITableView().then {
    $0.backgroundColor = .clear
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
    $0.setTitle("수정하기", for: .normal)
    $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    $0.setBackgroundColor(UIColor.init(r: 200, g: 200, b: 200), for: .disabled)
    $0.setBackgroundColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
    $0.layer.masksToBounds = true
  }
  
  let containerView = UIView().then {
    $0.isUserInteractionEnabled = true
  }
  
  let scrollView = UIScrollView().then {
    $0.isUserInteractionEnabled = true
  }
  
  lazy var dimView = UIView(frame: self.frame).then {
    $0.backgroundColor = .clear
  }
  
  override func setup() {
    backgroundColor = .white
    scrollView.delegate = self
    addGestureRecognizer(bgTap)
    setupNavigationBar()
    navigationBar.addSubViews(backBtn, titleLabel, deleteBtn)
    containerView.addSubViews(mapView, titleContainer, repoterValueLabel,
                              repoterLabel, categoryLabel, nameField, imageLabel, imageCollection,
                              menuLabel, menuTableView)
    scrollView.addSubViews(containerView)
    addSubViews(scrollView, navigationBar, registerBtnBg, registerBtn)
    setupContainerShadow()
  }
  
  override func bindConstraints() {
    scrollView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
    
    navigationBar.snp.makeConstraints { (make) in
      make.left.right.top.equalToSuperview()
      make.height.equalTo(98)
    }
    
    backBtn.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(48)
      make.left.equalToSuperview().offset(24)
      make.width.height.equalTo(48)
    }
    
    titleLabel.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(backBtn.snp.centerY)
    }
    
    deleteBtn.snp.makeConstraints { (make) in
      make.centerY.equalTo(titleLabel)
      make.right.equalToSuperview().offset(-24)
    }
    
    mapView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalToSuperview().offset(43)
      make.height.equalTo(336)
    }
    
    titleContainer.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(mapView.snp.bottom)
      make.height.equalTo(150)
    }
    
    repoterValueLabel.snp.makeConstraints { (make) in
      make.left.equalTo(titleContainer).offset(16)
      make.top.equalTo(titleContainer).offset(16)
    }
    
    repoterLabel.snp.makeConstraints { (make) in
      make.left.equalTo(repoterValueLabel)
      make.top.equalTo(repoterValueLabel.snp.bottom).offset(-10)
    }
    
    categoryLabel.snp.makeConstraints { (make) in
      make.left.equalTo(repoterValueLabel)
      make.bottom.equalTo(titleContainer).offset(-20)
      make.width.equalTo(102)
      make.height.equalTo(40)
    }
    
    nameField.snp.makeConstraints { (make) in
      make.centerY.equalTo(categoryLabel)
      make.left.equalTo(categoryLabel.snp.right).offset(8)
      make.right.equalTo(titleContainer).offset(-16)
      make.height.equalTo(categoryLabel)
    }
    
    imageLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(titleContainer.snp.bottom).offset(40)
    }
    
    imageCollection.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(imageLabel.snp.bottom).offset(16)
      make.height.equalTo(110)
    }
    
    menuLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(imageCollection.snp.bottom).offset(32)
    }
    
    containerView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
      make.width.equalTo(frame.width)
      make.top.equalToSuperview()
      make.bottom.equalTo(menuTableView.snp.bottom)
    }
    
    registerBtnBg.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.equalTo(232)
      make.height.equalTo(72)
      make.bottom.equalToSuperview().offset(-32)
    }
    
    registerBtn.snp.makeConstraints { (make) in
      make.left.equalTo(registerBtnBg.snp.left).offset(8)
      make.right.equalTo(registerBtnBg.snp.right).offset(-8)
      make.top.equalTo(registerBtnBg.snp.top).offset(8)
      make.bottom.equalTo(registerBtnBg.snp.bottom).offset(-8)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    refreshScrollViewHeight()
    registerBtn.layer.cornerRadius = registerBtn.frame.height / 2
  }
  
  override func layoutIfNeeded() {
    super.layoutIfNeeded()
    refreshScrollViewHeight()
  }
  
  func setFieldEmptyMode(isEmpty: Bool) {
    if isEmpty {
      nameField.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
    } else {
      nameField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
    }
  }
  
  private func refreshScrollViewHeight() {
    menuTableView.snp.remakeConstraints({ (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(menuLabel.snp.bottom).offset(8)
      make.height.equalTo(menuTableView.contentSize.height + 85)
    })
  }
  
  private func setupContainerShadow() {
    let shadowLayer = CAShapeLayer()
    
    shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 48, height: 150), cornerRadius: 12).cgPath
    shadowLayer.fillColor = UIColor.white.cgColor
    
    shadowLayer.shadowColor = UIColor.black.cgColor
    shadowLayer.shadowPath = nil
    shadowLayer.shadowOffset = CGSize(width: 8.0, height: 8.0)
    shadowLayer.shadowOpacity = 0.06
    shadowLayer.shadowRadius = 5
    
    titleContainer.layer.insertSublayer(shadowLayer, at: 0)
  }
  
  private func setupNavigationBar() {
    navigationBar.layer.cornerRadius = 16
    navigationBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    
    navigationBar.layer.shadowOffset = CGSize(width: 8, height: 8)
    navigationBar.layer.shadowColor = UIColor.black.cgColor
    navigationBar.layer.shadowOpacity = 0.08
  }
  
  func setImageCount(count: Int) {
    let text = "총 \(count)개의 사진 제보!"
    let attributedText = NSMutableAttributedString(string: text)
    
    attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 16)!, range: (text as NSString).range(of: "\(count)개"))
    imageLabel.attributedText = attributedText
  }
  
  func setMenuCount(count: Int) {
    let text = "총 \(count)개의 메뉴 제보!"
    let attributedText = NSMutableAttributedString(string: text)
    
    attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 16)!, range: (text as NSString).range(of: "\(count)개"))
    menuLabel.attributedText = attributedText
  }
  
  func setCategory(category: StoreCategory?) {
    switch category {
    case .BUNGEOPPANG:
      categoryLabel.text = "붕어빵"
    case .GYERANPPANG:
      categoryLabel.text = "계란빵"
    case .HOTTEOK:
      categoryLabel.text = "호떡"
    case .TAKOYAKI:
      categoryLabel.text = "문어빵"
    default:
      break
    }
  }
  
  func setTitle(title: String) {
    nameField.text = title
  }
  
  func setRepoter(repoter: String) {
    let text = "\(repoter) 님이"
    let attributedText = NSMutableAttributedString(string: text)
    
    attributedText.addAttribute(.font, value: UIFont.init(name: "SpoqaHanSans-Bold", size: 24)!, range: (text as NSString).range(of: repoter))
    repoterValueLabel.attributedText = attributedText
  }
  
  func addBgDim() {
    DispatchQueue.main.async { [weak self] in
      if let vc = self {
        vc.addSubview(vc.dimView)
        UIView.animate(withDuration: 0.3) {
          vc.dimView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a:0.3)
        }
      }
      
    }
  }
  
  
  func removeBgDim() {
    DispatchQueue.main.async { [weak self] in
      UIView.animate(withDuration: 0.3, animations: {
        self?.dimView.backgroundColor = .clear
      }) { (_) in
        self?.dimView.removeFromSuperview()
      }
    }
  }
  
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

extension ModifyView: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    self.endEditing(true)
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

