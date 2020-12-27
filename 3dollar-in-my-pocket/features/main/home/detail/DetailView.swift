import UIKit

class DetailView: BaseView {
  
  let navigationBar = UIView().then {
    $0.backgroundColor = .white
  }
  
  let backBtn = UIButton().then {
    $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
  }
  
  let titleLabel = UILabel().then {
    $0.text = "강남역 10번 출구"
    $0.textColor = UIColor.init(r: 51, g: 51, b: 51)
    $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    $0.textAlignment = .center
  }
  
  let shareButton = UIButton().then {
    $0.setTitle("공유하기", for: .normal)
    $0.setTitleColor(UIColor(r: 238, g: 98, b: 76), for: .normal)
    $0.titleLabel?.font = UIFont(name: "SpoqaHanSans-Bold", size: 14)
  }
  
  let tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.tableFooterView = UIView()
    $0.separatorStyle = .none
    $0.backgroundColor = .white
    $0.rowHeight = UITableView.automaticDimension
    $0.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
  }
  
  lazy var dimView = UIView(frame: self.frame).then {
    $0.backgroundColor = .clear
  }
  
  override func setup() {
    setupNavigationBar()
    navigationBar.addSubViews(backBtn, titleLabel, shareButton)
    addSubViews(tableView, navigationBar)
    backgroundColor = UIColor(r: 250, g: 250, b: 250)
  }
  
  override func bindConstraints() {
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
      make.left.equalTo(backBtn.snp.right)
      make.right.equalToSuperview().offset(-72)
      make.centerY.equalTo(backBtn.snp.centerY)
    }
    
    shareButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.backBtn)
      make.right.equalToSuperview().offset(-24)
    }
    
    tableView.snp.makeConstraints { (make) in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(navigationBar.snp.bottom).offset(-20)
    }
  }
  
  private func setupNavigationBar() {
    navigationBar.layer.cornerRadius = 16
    navigationBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    
    navigationBar.layer.shadowOffset = CGSize(width: 8, height: 8)
    navigationBar.layer.shadowColor = UIColor.black.cgColor
    navigationBar.layer.shadowOpacity = 0.08
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
  
}
