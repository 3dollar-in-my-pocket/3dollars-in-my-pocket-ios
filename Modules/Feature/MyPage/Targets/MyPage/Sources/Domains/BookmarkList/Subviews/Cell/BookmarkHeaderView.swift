import UIKit

import Common
import DesignSystem

final class BookmarkSectionHeaderView: UICollectionReusableView {
    enum Layout {
        static let height: CGFloat = 54
    }
    
    private let countLabel: UILabel = {
        let label = UILabel()
        
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.mainPink.color
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("삭제하기", for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        return button
    }()
    
    let deleteAllButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("모두 삭제", for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        return button
    }()
    
    let finishButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("완료", for: .normal)
        button.setTitleColor(Colors.gray60.color, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.backgroundColor = Colors.gray95.color
        button.layer.cornerRadius = 11
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 12, bottom: 2, right: 12)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubViews([
            countLabel,
            deleteButton,
            deleteAllButton,
            finishButton
        ])
    }
    
    private func bindConstraints() {
        countLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(24)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(countLabel)
        }
        
        finishButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(countLabel)
            $0.height.equalTo(22)
        }
        
        deleteAllButton.snp.makeConstraints {
            $0.centerY.equalTo(countLabel)
            $0.trailing.equalTo(finishButton.snp.leading).offset(-12)
        }
    }
    
//    fileprivate func bind(totalCount: Int) {
//        self.countLabel.text = "\(totalCount)개의 리스트"
//    }
//    
//    fileprivate func setDeleteMode(isDeleteMode: Bool) {
//        UIView.transition(with: self, duration: 0.3) { [weak self] in
//            self?.deleteButton.alpha = isDeleteMode ? 0 : 1
//            self?.deleteAllButton.alpha = isDeleteMode ? 1 : 0
//            self?.finishButton.alpha = isDeleteMode ? 1 : 0
//        }
//    }
}
