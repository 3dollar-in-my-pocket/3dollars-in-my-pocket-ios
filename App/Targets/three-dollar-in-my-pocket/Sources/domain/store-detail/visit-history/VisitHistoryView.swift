import UIKit

import RxSwift
import RxCocoa

final class VisitHistoryView: BaseView {
    let tapBackgroundGesture = UITapGestureRecognizer()
    
    private let backgroundView = UIView()
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 0)
        $0.layer.shadowOpacity = 0.08
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .light(size: 24)
        $0.numberOfLines = 0
    }
    
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close_24"), for: .normal)
    }
    
    private let successContainerView = UIView().then {
        $0.backgroundColor = UIColor(r: 0, g: 198, b: 103)
        $0.layer.cornerRadius = 24
        $0.alpha = 0.1
    }
    
    private let successImage = UIImageView().then {
        $0.image = UIImage(named: "img_face_success")
    }
    
    private let successCountLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = UIColor(r: 0, g: 198, b: 103)
    }
    
    private let failContainerView = UIView().then {
        $0.backgroundColor = UIColor(r: 255, g: 92, b: 67)
        $0.layer.cornerRadius = 24
        $0.alpha = 0.1
    }
    
    private let failImage = UIImageView().then {
        $0.image = UIImage(named: "img_face_fail")
    }
    
    private let failCountLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = UIColor(r: 255, g: 92, b: 67)
    }
    
    private let tableView = UITableView().then {
        $0.tableFooterView = UIView()
        $0.backgroundColor = Color.gray0
        $0.layer.cornerRadius = 12
        $0.rowHeight = UITableView.automaticDimension
        $0.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
        $0.separatorStyle = .none
        $0.register(
            VisitHistoryTableViewCell.self,
            forCellReuseIdentifier: VisitHistoryTableViewCell.registerId
        )
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.backgroundView.addGestureRecognizer(self.tapBackgroundGesture)
        self.addSubViews([
            self.backgroundView,
            self.containerView,
            self.titleLabel,
            self.closeButton,
            self.successContainerView,
            self.successImage,
            self.successCountLabel,
            self.failContainerView,
            self.failImage,
            self.failCountLabel,
            self.tableView
        ])
    }
    
    override func bindConstraints() {
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            make.top.equalTo(self.titleLabel).offset(-32)
        }
        
        self.tableView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
            make.bottom.equalTo(self.containerView).offset(-24)
            make.height.equalTo(188)
        }
        
        self.successContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.bottom.equalTo(self.tableView.snp.top).offset(-16)
            make.height.equalTo(48)
            make.right.equalTo(self.snp.centerX).offset(-7)
        }
        
        self.successImage.snp.makeConstraints { make in
            make.left.equalTo(self.successContainerView).offset(8)
            make.top.equalTo(self.successContainerView).offset(8)
            make.bottom.equalTo(self.successContainerView).offset(-8)
            make.width.height.equalTo(32)
        }
        
        self.successCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.successImage)
            make.left.equalTo(self.successImage.snp.right).offset(8)
            make.right.equalTo(self.successContainerView).offset(-8)
        }
        
        self.failContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.centerX).offset(7)
            make.right.equalTo(self.tableView)
            make.top.equalTo(self.successContainerView)
            make.bottom.equalTo(self.successContainerView)
        }
        
        self.failImage.snp.makeConstraints { make in
            make.left.equalTo(self.failContainerView).offset(8)
            make.top.equalTo(self.failContainerView).offset(8)
            make.bottom.equalTo(self.failContainerView).offset(-8)
            make.width.height.equalTo(32)
        }
        
        self.failCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.failImage)
            make.left.equalTo(self.failImage.snp.right).offset(8)
            make.right.equalTo(self.failContainerView).offset(-8)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(24)
            make.bottom.equalTo(self.successContainerView.snp.top).offset(-16)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.right.equalTo(self.containerView).offset(-24)
            make.top.equalTo(self.titleLabel)
        }
    }
    
    func bind(visitHistories: [VisitHistory]) {
        let existsCounts = visitHistories.filter { $0.type == .exists }.count
        let notExistsCounts = visitHistories.filter { $0.type == .notExists }.count
        
        self.successCountLabel.text = "\(existsCounts)명"
        self.failCountLabel.text = "\(notExistsCounts)명"
        self.setTotalCountLabel(count: visitHistories.count)
        
        Observable<[VisitHistory]>.just(visitHistories)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(
                cellIdentifier: VisitHistoryTableViewCell.registerId,
                cellType: VisitHistoryTableViewCell.self
            )) { _, visitHistory, cell in
                cell.bind(visitHistory: visitHistory)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func setTotalCountLabel(count: Int) {
        let string = String(format: "visit_history_total_count".localized, count)
        let attributedString = NSMutableAttributedString(string: string)
        let range = (string as NSString).range(of: "\(count)명")
        
        attributedString.addAttribute(
            .font,
            value: UIFont.semiBold(size: 24) as Any,
            range: range
        )
        self.titleLabel.attributedText = attributedString
    }
}
