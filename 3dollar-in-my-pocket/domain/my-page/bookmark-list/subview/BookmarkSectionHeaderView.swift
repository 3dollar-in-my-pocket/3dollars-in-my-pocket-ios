import UIKit

import RxSwift
import RxCocoa

final class BookmarkSectionHeaderView: BaseCollectionReusableView {
    static let registerId = "\(BookmarkSectionHeaderView.self)"
    static let height: CGFloat = 50
    
    private let countLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = R.color.gray20()
        $0.text = "4개의 리스트"
    }
    
    let deleteButton = UIButton().then {
        $0.setTitle("bookmark_list_delete".localized, for: .normal)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .medium(size: 12)
    }
    
    let deleteAllButton = UIButton().then {
        $0.setTitle("bookmark_list_delete_all".localized, for: .normal)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .medium(size: 12)
    }
    
    let finishButton = UIButton().then {
        $0.setTitle("bookmark_list_finish".localized, for: .normal)
        $0.setTitleColor(R.color.gray20(), for: .normal)
        $0.titleLabel?.font = .medium(size: 12)
        $0.backgroundColor = R.color.gray80()
        $0.layer.cornerRadius = 13
        $0.contentEdgeInsets = .init(top: 4, left: 13, bottom: 4, right: 13)
    }
    
    override func setup() {
        self.addSubViews([
            self.countLabel,
            self.deleteButton,
            self.deleteAllButton,
            self.finishButton
        ])
    }
    
    override func bindConstraints() {
        self.countLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(28)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.countLabel)
        }
        
        self.finishButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(self.countLabel)
            make.height.equalTo(26)
        }
        
        self.deleteAllButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.countLabel)
            make.right.equalTo(self.finishButton.snp.left).offset(-16)
        }
    }
    
    fileprivate func bind(totalCount: Int) {
        self.countLabel.text = "\(totalCount)개의 리스트"
    }
    
    fileprivate func setDeleteMode(isDeleteMode: Bool) {
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.deleteButton.alpha = isDeleteMode ? 0 : 1
            self?.deleteAllButton.alpha = isDeleteMode ? 1 : 0
            self?.finishButton.alpha = isDeleteMode ? 1 : 0
        }
    }
}

extension Reactive where Base: BookmarkSectionHeaderView {
    var totalCount: Binder<Int> {
        return Binder(self.base) { base, totalCount in
            base.bind(totalCount: totalCount)
        }
    }
    
    var isDeleteMode: Binder<Bool> {
        return Binder(self.base) { base, isDeleteMode in
            base.setDeleteMode(isDeleteMode: isDeleteMode)
        }
    }
}
