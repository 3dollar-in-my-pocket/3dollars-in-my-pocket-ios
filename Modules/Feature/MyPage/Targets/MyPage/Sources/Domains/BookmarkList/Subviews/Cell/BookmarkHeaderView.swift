import UIKit
import Combine

import Common
import DesignSystem

final class BookmarkSectionHeaderView: UICollectionReusableView {
    var cancellables = Set<AnyCancellable>()
    
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
        button.alpha = 0
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
        button.alpha = 0
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
    
    func bind(_ viewModel: BookmarkSectionHeaderViewModel) {
        deleteButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapDeleteMode)
            .store(in: &cancellables)
        
        deleteAllButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapDeleteAll)
            .store(in: &cancellables)
        
        finishButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapFinish)
            .store(in: &cancellables)
        
        viewModel.output.totalCount
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkSectionHeaderView, totalCount: Int?) in
                owner.bind(totalCount: totalCount)
            }
            .store(in: &cancellables)
        
        viewModel.output.isDeleteMode
            .main
            .withUnretained(self)
            .sink { (owner: BookmarkSectionHeaderView, isDeleteMode: Bool) in
                owner.setDeleteMode(isDeleteMode: isDeleteMode)
            }
            .store(in: &cancellables)
    }
    
    private func bind(totalCount: Int?) {
        let text: String?
        
        if let totalCount {
            text = "\(totalCount)개의 리스트"
        } else {
            text = nil
        }
        countLabel.text = text
    }
    
    private func setDeleteMode(isDeleteMode: Bool) {
        UIView.transition(with: self, duration: 0.3) { [weak self] in
            self?.deleteButton.alpha = isDeleteMode ? 0 : 1
            self?.deleteAllButton.alpha = isDeleteMode ? 1 : 0
            self?.finishButton.alpha = isDeleteMode ? 1 : 0
        }
    }
}
