import UIKit

import Common
import DesignSystem

final class BossStoreDetailCouponHeaderView: BaseCollectionViewReusableView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        rightButton.setTitle(nil, for: .normal)
    }
    
    override func setup() {
        addSubViews([
            titleLabel,
            rightButton
        ])
    }
    
    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(18)
        }
    }
    
    func bind(_ viewModel: BossStoreDetailCouponHeaderViewModel) {
        titleLabel.text = viewModel.output.title

        rightButton.setTitle(viewModel.output.buttonTitle, for: .normal)
      
        rightButton.tapPublisher
            .subscribe(viewModel.input.didTapRightButton)
            .store(in: &cancellables)
    }
}
