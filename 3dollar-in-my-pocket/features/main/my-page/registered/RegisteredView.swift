import UIKit

class RegisteredView: BaseView {
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_back_white"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "등록한 음식점"
        $0.textColor = .white
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let bgCloud = UIImageView().then {
        $0.image = UIImage.init(named: "bg_cloud_my_page")
        $0.alpha = 0.2
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.tableFooterView = UIView()
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableView.automaticDimension
        $0.contentInsetAdjustmentBehavior = .never
    }
    
    override func setup() {
        backgroundColor = UIColor.init(r: 28, g: 28, b: 28)
        addSubViews(backBtn, titleLabel, bgCloud, tableView)
    }
    
    override func bindConstraints() {
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(48)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        bgCloud.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(98)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-24)
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(bgCloud.snp.top)
        }
    }
}
