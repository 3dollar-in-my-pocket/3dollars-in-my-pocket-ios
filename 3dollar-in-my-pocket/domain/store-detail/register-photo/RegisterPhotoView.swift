import UIKit

class RegisterPhotoView: BaseView {
  
  let navigationView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
  }
  
  let closeButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_close"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
    $0.textColor = .black
    $0.text = "register_photo_title".localized
  }
  
  let photoCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 8
    layout.minimumLineSpacing = 8
    layout.itemSize = CGSize(
      width: (Int(UIScreen.main.bounds.width) - 64)/3,
      height: (Int(UIScreen.main.bounds.width) - 64)/3
    )
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
    $0.contentInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    $0.allowsMultipleSelection = true
  }
  
  let registerButtonBg = UIView().then {
    $0.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.6)
    $0.layer.cornerRadius = 32
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.1
    $0.layer.shadowOffset = CGSize(width: 10, height: 10)
  }
  
  let registerButton = UIButton().then {
    $0.setTitle(String(format: "register_photo_button_format".localized, 0), for: .normal)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.isEnabled = false
    $0.setBackgroundColor(UIColor.init(r: 208, g: 208, b: 208), for: .disabled)
    $0.setBackgroundColor(UIColor.init(r: 255, g: 92, b: 67), for: .normal)
    $0.layer.cornerRadius = 24
    $0.layer.masksToBounds = true
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    self.addSubViews(
      navigationView, closeButton, titleLabel, photoCollectionView,
      registerButtonBg, registerButton
    )
  }
  
  override func bindConstraints() {
    self.navigationView.snp.makeConstraints { make in
      make.left.top.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(60)
    }
    
    self.closeButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.navigationView).offset(-21)
    }
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(self.navigationView.snp.bottom)
    }
    
    self.registerButtonBg.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide).offset(-34)
      make.width.equalTo(232)
      make.height.equalTo(64)
    }
    
    self.registerButton.snp.makeConstraints { make in
      make.left.equalTo(self.registerButtonBg).offset(8)
      make.top.equalTo(self.registerButtonBg).offset(8)
      make.right.equalTo(self.registerButtonBg).offset(-8)
      make.bottom.equalTo(self.registerButtonBg).offset(-8)
    }
  }
    
    func deselectCollectionItem(index: Int) {
        self.photoCollectionView.deselectItem(
            at: IndexPath(row: index, section: 0),
            animated: true
        )
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
