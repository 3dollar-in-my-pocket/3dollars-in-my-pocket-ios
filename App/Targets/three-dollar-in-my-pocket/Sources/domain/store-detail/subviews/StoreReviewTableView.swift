import UIKit
import RxSwift

final class StoreReviewTableView: BaseView {
  
  private let titleLabel = UILabel().then {
    $0.textColor = Color.black
    $0.font = .semiBold(size: 18)
      $0.text = "store_detail_header_review".localized
    $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
  
  private let countLabel = UILabel().then {
    $0.font = .medium(size: 16)
      $0.textColor = Color.black
  }
  
  let addPhotoButton = UIButton().then {
      $0.setTitle("store_detail_header_add_review".localized, for: .normal)
    $0.setTitleColor(Color.red, for: .normal)
    $0.titleLabel?.font = .bold(size: 12)
    $0.layer.cornerRadius = 15
    $0.backgroundColor = Color.red?.withAlphaComponent(0.2)
    $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
  }
  
  let reviewTableView = UITableView().then {
    $0.backgroundColor = .clear
    $0.tableFooterView = UIView()
    $0.estimatedRowHeight = UITableView.automaticDimension
    $0.showsVerticalScrollIndicator = false
    $0.isScrollEnabled = false
    $0.separatorStyle = .none
  }
  
  override func setup() {
    self.backgroundColor = .clear
    self.addSubViews([
      self.titleLabel,
      self.countLabel,
      self.addPhotoButton,
      self.reviewTableView
    ])
  }
  
  override func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(46)
    }
    
    self.countLabel.snp.makeConstraints { make in
      make.left.equalTo(self.titleLabel.snp.right).offset(2)
      make.centerY.equalTo(self.titleLabel)
    }
    
    self.addPhotoButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.top.equalToSuperview().offset(40)
      make.height.equalTo(30)
    }
    
    self.reviewTableView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalToSuperview().offset(83)
      make.height.equalTo(0)
    }
    
    self.snp.makeConstraints { make in
      make.bottom.equalTo(self.reviewTableView)
    }
  }
  
  func bind(store: Store, userId: Int) {
      self.countLabel.text = String(
        format: "store_detail_header_count".localized,
        store.reviews.count
      )
  }
}
