import UIKit

class AddCategoryView: BaseView {
  
  let tapBackground = UITapGestureRecognizer()
  
  let backgroundView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
  }
  
  let titleLabel = UILabel().then {
    $0.text = "add_category_title".localized
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
  }
  
  let multiLabel = UILabel().then {
    $0.text = "add_category_multi".localized
    $0.textColor = UIColor(r: 255, g: 161, b: 170)
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 12)
  }
  
  let categoryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = LeftAlignedCollectionViewFlowLayout()
    
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 52, height: 72)
    layout.minimumInteritemSpacing = 16 * RatioUtils.widthRatio
    layout.minimumLineSpacing = 20
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
  }
  
  let selectButton = UIButton().then {
    $0.layer.cornerRadius = 24
    $0.setTitle("add_category_select".localized, for: .normal)
    $0.setBackgroundColor(UIColor(r: 255, g: 92, b: 67), for: .normal)
    $0.setBackgroundColor(UIColor(r: 208, g: 208, b: 208), for: .disabled)
    $0.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16)
    $0.setTitleColor(.white, for: .normal)
    $0.layer.masksToBounds = true
  }
  
  
  override func setup() {
    backgroundColor = .clear
    backgroundView.addGestureRecognizer(self.tapBackground)
    addSubViews(backgroundView, containerView, selectButton, categoryCollectionView, titleLabel, multiLabel)
  }
  
  override func bindConstraints() {
    self.backgroundView.snp.makeConstraints { make in
      make.edges.equalTo(0)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(self.titleLabel).offset(-32)
    }
    
    self.selectButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-15)
      make.height.equalTo(48)
    }
    
    self.categoryCollectionView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.right.equalToSuperview().offset(-24)
      make.bottom.equalTo(self.selectButton.snp.top).offset(-32)
      make.height.equalTo(72)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.bottom.equalTo(self.categoryCollectionView.snp.top).offset(-16)
    }
    
    self.multiLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.titleLabel)
    }
  }
  
}
