import UIKit
import RxSwift
import RxCocoa

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
        $0.rowHeight = RegisteredStoreCell.size.height
        $0.contentInsetAdjustmentBehavior = .never
        $0.separatorStyle = .none
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
    
    private let headerView = UIView()
    
    fileprivate let headerCountLabel = UILabel().then {
        $0.font = .regular(size: 24)
        $0.textColor = .white
        $0.text = "0개 제보하셨네요."
    }
    
    let emptyView = RegisteredStoreEmptyView().then {
        $0.isHidden = true
    }
    
    
    override func setup() {
        self.backgroundColor = .black
        self.headerView.addSubview(self.headerCountLabel)
        self.tableView.tableHeaderView = headerView
        self.addSubViews([
            self.backButton,
            self.titleLabel,
            self.tableView,
            self.emptyView
        ])
    }
    
    override func bindConstraints() {
        self.headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.headerCountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
        
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
        
        self.emptyView.snp.makeConstraints { make in
            make.edges.equalTo(self.tableView)
        }
    }
    
    fileprivate func setStoreCount(count: Int) {
        let string = "\(count)개 제보하셨네요!"
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: "\(count)개")
        
        attributedString.addAttribute(
            .font,
            value: UIFont.bold(size: 24) as Any,
            range: range
        )
        self.headerCountLabel.attributedText = attributedString
        self.headerCountLabel.isHidden = count == 0
    }
}

extension Reactive where Base: RegisteredStoreView {
    var isHiddenFooter: Binder<Bool> {
        return Binder(self.base) { view, isHidden in
            view.tableView.tableFooterView?.isHidden = isHidden
        }
    }
    
    var storeCounts: Binder<Int> {
        return Binder(self.base) { view, count in
            view.setStoreCount(count: count)
        }
    }
}
