import UIKit
import Combine

import Common
import DesignSystem

final class SettingMenuCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 56)
    }
    
    let switchValue = PassthroughSubject<Bool, Never>()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.gray95.color
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.regular.font(size: 14)
        label.textAlignment = .left
        
        return label
    }()
    
    let switchButton: UISwitch = {
        let button = UISwitch()
        button.onTintColor = Colors.mainPink.color
        
        return button
    }()
    
    private let rightArrowImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = Icons.arrowRight.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.systemWhite.color
        return imageView
    }()
    
    override func setup() {
        switchButton.transform = .init(scaleX: 0.8, y: 0.8)
        
        contentView.addSubViews([
            containerView,
            titleLabel,
            switchButton,
            rightArrowImage
        ])
    }
    
    override func bindConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(containerView)
            $0.leading.equalTo(containerView).offset(16)
            $0.trailing.lessThanOrEqualTo(switchButton.snp.leading).offset(-12)
        }
        
        switchButton.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.centerY.equalTo(containerView)
        }
        
        rightArrowImage.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.centerY.equalTo(containerView)
            $0.size.equalTo(12)
        }
    }
    
    func bind(cellType: SettingCellType) {
        titleLabel.text = cellType.title
        switchButton.isHidden = cellType.isHiddenSwitch
        rightArrowImage.isHidden = cellType.isHiddenArrow
        
        switch cellType {
        case .account, .signout, .qna, .agreement, .teamInfo, .accountInfo:
            break
        case .activityNotification(let isOn):
            switchButton.isOn = isOn
        case .marketingNotification(let isOn):
            switchButton.isOn = isOn
        }
        
        switchButton.controlPublisher(for: .valueChanged)
            .compactMap { [weak self] _ in
                self?.switchButton.isOn
            }
            .subscribe(switchValue)
            .store(in: &cancellables)
    }
}
