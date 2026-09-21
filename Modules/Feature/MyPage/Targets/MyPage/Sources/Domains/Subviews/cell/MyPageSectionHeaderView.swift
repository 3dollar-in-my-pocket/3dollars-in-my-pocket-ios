import UIKit
import Combine
import SnapKit

import Model
import DesignSystem
import Common

final class MyPageSectionHeaderView: BaseCollectionViewReusableView {
    enum Layout {
        static let height: CGFloat = 66
    }

    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.tintColor = Colors.gray50.color
        return iconView
    }()
    
    private let iconLabel: UILabel = {
        let iconLabel = UILabel()
        iconLabel.font = Fonts.medium.font(size: 12)
        iconLabel.textColor = Colors.gray50.color
        return iconLabel
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 20)
        titleLabel.textColor = Colors.gray10.color
        return titleLabel
    }()
    
    fileprivate let countButton: UIButton = {
        let countButton = UIButton()
        countButton.setTitle("0개", for: .normal)
        countButton.titleLabel?.font = Fonts.semiBold.font(size: 14)
        countButton.imageEdgeInsets.left = 2
        countButton.semanticContentAttribute = .forceRightToLeft
        countButton.setTitleColor(Colors.mainPink.color, for: .normal)
        countButton.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 12)
            .withTintColor(Colors.gray20.color), for: .normal)
        return countButton
    }()
    
    override func setup() {
        super.setup()
        
        backgroundColor = Colors.gray100.color
        
        addSubViews([
            iconView,
            iconLabel,
            titleLabel,
            countButton
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.size.equalTo(16)
        }
        
        iconLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.iconView)
            $0.leading.equalTo(self.iconView.snp.trailing).offset(4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(self.iconView)
            $0.top.equalTo(self.iconView.snp.bottom).offset(4)
        }
        
        countButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(self.titleLabel)
            $0.height.equalTo(20)
        }
    }
    
    func bind(viewModel: MyPageSectionHeaderViewModel) {
        let type = viewModel.output.item
        
        iconView.image = type.icon?.withRenderingMode(.alwaysTemplate)
        iconLabel.text = type.iconLabel
        titleLabel.text = type.title
        countButton.isHidden = type == .poll
        
        viewModel.output.count
            .compactMap { $0 }
            .main
            .withUnretained(self)
            .sink { owner, count in
                owner.countButton.setTitle("\(count)개", for: .normal)
            }.store(in: &cancellables)
        
        countButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapCountButton)
            .store(in: &cancellables)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        countButton.isHidden = true
    }
}
