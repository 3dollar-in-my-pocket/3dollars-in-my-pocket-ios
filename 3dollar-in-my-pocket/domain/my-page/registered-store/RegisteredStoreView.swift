import UIKit

final class RegisteredStoreView: BaseView {
    
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_white(), for: .normal)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = R.string.localization.registered_store_title()
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
    }
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.rowHeight = UITableView.automaticDimension
        $0.contentInsetAdjustmentBehavior = .never
        $0.register(
            RegisteredStoreCell.self,
            forCellReuseIdentifier: RegisteredStoreCell.registerId
        )
        
        let indicator = UIActivityIndicatorView(style: .large)
        
        indicator.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: 60
        )
        $0.tableFooterView = indicator
    }
    
    
    override func setup() {
        self.backgroundColor = .black
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.tableView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(13)
            make.width.height.equalTo(24)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.backButton)
            make.centerX.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.safeAreaLayoutGuide)
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(self.backButton.snp.bottom).offset(10)
        }
    }
}
