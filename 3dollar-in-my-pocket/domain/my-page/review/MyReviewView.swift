import UIKit

final class MyReviewView: BaseView {
    let backButton = UIButton().then {
        $0.setImage(R.image.ic_back_white(), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = R.string.localization.my_review_title()
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
    }
    
    let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.backgroundColor = .clear
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.addIndicatorFooter()
        $0.register(MyReviewCell.self, forCellReuseIdentifier: MyReviewCell.registerId)
    }
    
    let emptyView = MyReviewEmptyView().then {
        $0.isHidden = true
    }
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.tableView,
            self.emptyView
        ])
    }
    
    override func bindConstraints() {
        self.backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
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
        
        self.emptyView.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
    }
}
