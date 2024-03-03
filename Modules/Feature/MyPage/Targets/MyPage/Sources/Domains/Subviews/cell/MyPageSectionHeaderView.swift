import UIKit
import Combine
import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MyPageSectionHeaderView: BaseCollectionViewReusableView {
    enum Layout {
        static let height: CGFloat = 66
    }

    private let iconView = UIImageView().then {
        $0.tintColor = Colors.gray50.color
    }
    
    private let iconLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.textColor = Colors.gray10.color
    }
    
    fileprivate let countButton = UIButton().then {
        $0.setTitle("0개", for: .normal)
        $0.titleLabel?.font = Fonts.semiBold.font(size: 14)
        $0.imageEdgeInsets.left = 2
        $0.semanticContentAttribute = .forceRightToLeft
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 12)
            .withTintColor(Colors.gray20.color), for: .normal)
    }
    
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
