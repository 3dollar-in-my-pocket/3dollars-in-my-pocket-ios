import UIKit
import RxSwift

class StoreDetailHeaderView: UITableViewHeaderFooterView {
  
  static let registerId = "\(StoreDetailHeaderView.self)"
  var disposeBag = DisposeBag()
  
  let titleLabel = UILabel().then {
    $0.text = "헤더 이름"
    $0.textColor = .black
    $0.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
  }
  
  let rightButton = UIButton().then {
    $0.setTitle("버튼 제목", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.titleLabel?.font = UIFont(name: "SpoqaHanSans-Bold", size: 12)
    $0.layer.cornerRadius = 15
    $0.backgroundColor = UIColor(r: 255, g: 92, b: 67)
    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    
    self.setup()
    self.bindConstraints()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.disposeBag = DisposeBag()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .clear
    tintColor = .clear
    addSubViews(titleLabel, rightButton)
  }
  
  private func bindConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(24)
      make.top.equalToSuperview().offset(40)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-24)
      make.centerY.equalTo(self.titleLabel)
      make.height.equalTo(30)
      make.bottom.equalToSuperview()
    }
  }
  
  func bind(section: StoreDetailSection, count: Int?) {
    switch section {
    case .info:
      self.titleLabel.text =  "store_detail_header_info".localized
      self.rightButton.setTitle("store_detail_header_modify_info".localized, for: .normal)
    case .photo:
      self.titleLabel.text =  String(format: "store_detail_header_photo".localized, count ?? 0)
      self.rightButton.setTitle("store_detail_header_add_photo".localized, for: .normal)
    case .review:
      self.titleLabel.text =  String(format: "store_detail_header_review".localized, count ?? 0)
      self.rightButton.setTitle("store_detail_header_add_review".localized, for: .normal)
    default:
      break
    }
  }
}
