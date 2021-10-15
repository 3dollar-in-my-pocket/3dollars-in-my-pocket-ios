import UIKit

class CategoryView: BaseView {
  
  let titleLabel = UILabel().then {
    let text = "category_title".localized
    let attributedString = NSMutableAttributedString(string: text)
    let boldTextRange = (text as NSString).range(of: "네 최애")
    
    attributedString.addAttribute(
      .font,
      value: UIFont(name: "AppleSDGothicNeoEB00", size: 24)!,
      range: boldTextRange
    )
    $0.font = UIFont(name: "AppleSDGothicNeo-Light", size: 24)
    $0.attributedText = attributedString
    $0.textColor = .black
  }
  
  let categoryCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    layout.minimumInteritemSpacing = 11
    layout.minimumLineSpacing = 16
    layout.itemSize = CGSize(
      width: (UIScreen.main.bounds.width - 48 - 22)/3,
      height: (UIScreen.main.bounds.width - 48 - 22)/3
    )
    layout.scrollDirection = .vertical
    
    $0.collectionViewLayout = layout
    $0.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    $0.showsVerticalScrollIndicator = false
    $0.clipsToBounds = false
  }
  
  
  override func setup() {
    self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
    self.addSubViews(titleLabel, categoryCollectionView)
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalTo(safeAreaLayoutGuide).offset(35)
    }
    
    self.categoryCollectionView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(safeAreaLayoutGuide)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(32)
    }
  }
}
