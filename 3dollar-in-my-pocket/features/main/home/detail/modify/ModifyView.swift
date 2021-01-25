import UIKit
import NMapsMap

class ModifyView: BaseView {
  
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
    $0.text = "store_modify_title".localized
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = .black
  }
  
  let scrollView = UIScrollView().then {
    $0.showsVerticalScrollIndicator = false
  }
  
  let containerView = UIView()
  
  let mapView = NMFMapView()
  
  let titleContainer = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
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
  
  override func setup() {
    backgroundColor = UIColor(r: 250, g: 250, b: 250)
    scrollView.delegate = self
    addGestureRecognizer(bgTap)
    
    containerView.addSubViews(
      mapView, titleContainer, menuTableView
    )
    scrollView.addSubViews(containerView)
    addSubViews(
      scrollView, navigationView, backButton, titleLabel,
      registerBtnBg, registerBtn
    )
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
    
    titleContainer.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(mapView.snp.bottom)
      make.height.equalTo(150)
    }
    
    containerView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
      make.width.equalTo(frame.width)
      make.top.equalToSuperview()
      make.bottom.equalTo(menuTableView.snp.bottom)
    }
    
    self.mapView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(50)
      make.height.equalTo(350)
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
  
  private func refreshScrollViewHeight() {
    menuTableView.snp.remakeConstraints({ (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(menuTableView).offset(8)
      make.height.equalTo(menuTableView.contentSize.height + 85)
    })
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

