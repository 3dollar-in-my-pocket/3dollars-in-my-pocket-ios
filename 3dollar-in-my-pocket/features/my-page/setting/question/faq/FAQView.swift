import UIKit

class FAQView: BaseView {
  
  let backButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_back_white"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "faq_title".localized
    $0.textColor = .white
    $0.font = UIFont(name: "SpoqaHanSans-Bold", size: 16)
  }
  
  let topLineView = UIView().then {
    $0.backgroundColor = UIColor(r: 43, g: 43, b: 43)
  }
  
  let questionLabel = UILabel().then {
    $0.text = "faq_question".localized
    $0.font = UIFont(name: "SpoqaHanSans-Light", size: 24)
    $0.textColor = .white
    $0.textAlignment = .center
  }
  
  let tagCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 14 * RatioUtils.widthRatio
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    
    $0.collectionViewLayout = layout
    $0.backgroundColor = .clear
  }
  
  let faqTableView = UITableView(frame: .zero, style: .grouped).then {
    $0.tableFooterView = UIView()
    $0.separatorStyle = .none
    $0.backgroundColor = .clear
    $0.contentInsetAdjustmentBehavior = .never
    $0.rowHeight = UITableView.automaticDimension
    $0.sectionHeaderHeight = 70
    $0.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
  }
  
  override func setup() {
    backgroundColor = UIColor(r: 28, g: 28, b: 28)
    addSubViews(
      backButton, titleLabel, topLineView,
      questionLabel, tagCollectionView, faqTableView
    )
  }
  
  override func bindConstraints() {
    self.backButton.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.top.equalToSuperview().offset(48)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.backButton)
    }
    
    self.topLineView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.height.equalTo(1)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
    }
    
    self.questionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.topLineView.snp.bottom).offset(40)
    }
    
    self.tagCollectionView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24 * RatioUtils.widthRatio)
      make.right.equalToSuperview().offset(-24 * RatioUtils.widthRatio)
      make.top.equalTo(self.questionLabel.snp.bottom).offset(16)
      make.height.equalTo(80)
    }
    
    self.faqTableView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(self.tagCollectionView.snp.bottom)
    }
  }
}
