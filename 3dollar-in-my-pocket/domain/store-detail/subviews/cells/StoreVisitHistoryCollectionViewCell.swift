import UIKit

import RxSwift
import RxCocoa

final class StoreVisitHistoryCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(StoreVisitHistoryCollectionViewCell.self)"
    static let height: CGFloat = 108
    
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 18)
        $0.textColor = .black
    }
    
    private let bedgeImage = UIImageView().then {
        $0.image = UIImage(named: "img_bedge")
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let existImage = UIImageView()
    
    private let existLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = Color.gray30
    }
    
    private let notExistImage = UIImageView()
    
    private let notExistLabel = UILabel().then {
        $0.font = .bold(size: 16)
        $0.textColor = Color.gray30
    }
    
    fileprivate let plusButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_plus_black"), for: .normal)
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.bedgeImage,
            self.containerView,
            self.existImage,
            self.existLabel,
            self.notExistImage,
            self.notExistLabel,
            self.plusButton
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview()
        }
        
        self.bedgeImage.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(24)
            make.width.height.equalTo(32)
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalTo(self.bedgeImage.snp.right).offset(15)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
            make.height.equalTo(48)
        }
        
        self.existImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(10)
            make.centerY.equalTo(self.containerView)
            make.width.height.equalTo(24)
        }
        
        self.existLabel.snp.makeConstraints { make in
            make.left.equalTo(self.existImage.snp.right).offset(10)
            make.centerY.equalTo(self.existImage)
        }
        
        self.notExistImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView.snp.centerX)
            make.centerY.equalTo(self.containerView)
            make.width.height.equalTo(24)
        }
        
        self.notExistLabel.snp.makeConstraints { make in
            make.left.equalTo(self.notExistImage.snp.right).offset(10)
            make.centerY.equalTo(self.notExistImage)
        }
        
        self.plusButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.width.height.equalTo(32)
        }
        
        self.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel).priority(.high)
            make.bottom.equalTo(self.containerView).priority(.high)
        }
    }
    
    func bind(visitOverview: VisitOverview) {
        let isEmpty = visitOverview.existsCounts == 0 && visitOverview.notExistsCounts == 0
        
        self.setupTitleLabel(isEmpty: isEmpty, count: visitOverview.existsCounts)
        self.setupExist(count: visitOverview.existsCounts)
        self.setupNotExist(count: visitOverview.notExistsCounts)
    }
    
    private func setupTitleLabel(isEmpty: Bool, count: Int) {
        if isEmpty {
            let text = "store_detail_empty_visit_history".localized
            let attributedString = NSMutableAttributedString(string: text)
            let boldTextRange = (text as NSString).range(of: "방문 인증")
            
            attributedString.addAttribute(
                .font,
                value: UIFont.extraBold(size: 18) as Any,
                range: boldTextRange
            )
            self.titleLabel.attributedText = attributedString
        } else {
            let text = String(format: "store_detail_visit_history".localized, count)
            let attributedString = NSMutableAttributedString(string: text)
            let boldTextRange = (text as NSString).range(of: "\(count)명")
            
            attributedString.addAttribute(
                .font,
                value: UIFont.extraBold(size: 18) as Any,
                range: boldTextRange
            )
            self.titleLabel.attributedText = attributedString
        }
    }
    
    private func setupExist(count: Int) {
        self.existImage.image = count == 0
        ? UIImage(named: "img_exist_empty")
        : UIImage(named: "img_exist")
        self.existLabel.textColor = count == 0 ? Color.gray30 : UIColor(r: 0, g: 198, b: 103)
        self.existLabel.text = "\(count) 명"
    }
    
    private func setupNotExist(count: Int) {
        self.notExistImage.image =
        count == 0
        ? UIImage(named: "img_not_exist_empty")
        : UIImage(named: "img_not_exist")
        self.notExistLabel.textColor = count == 0 ? Color.gray30 : Color.red
        self.notExistLabel.text = "\(count) 명"
    }
}

extension Reactive where Base: StoreVisitHistoryCollectionViewCell {
    var tap: ControlEvent<Void> {
        return base.plusButton.rx.tap
    }
}
