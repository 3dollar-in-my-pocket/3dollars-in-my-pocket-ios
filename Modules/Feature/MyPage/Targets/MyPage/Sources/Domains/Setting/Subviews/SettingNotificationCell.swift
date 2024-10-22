import UIKit
import Combine

import Common

final class SettingNotificationCell: BaseCollectionViewCell {
    enum Layout {
        static let size = CGSize(width: UIUtils.windowBounds.width, height: 72)
    }
    
    let switchValue = PassthroughSubject<Bool, Never>()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.gray95.color
        
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.regular.font(size: 14)
        label.textAlignment = .left
        
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        label.textAlignment = .left
        return label
    }()
    
    let switchButton: UISwitch = {
        let button = UISwitch()
        button.onTintColor = Colors.mainPink.color
        
        return button
    }()
    
    override func setup() {
        setupUI()
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        contentView.addSubview(containerView)
        contentView.addSubview(stackView)
        contentView.addSubview(switchButton)
        
        switchButton.transform = .init(scaleX: 0.8, y: 0.8)
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.equalTo(containerView).offset(16)
            $0.trailing.equalTo(switchButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        switchButton.snp.makeConstraints {
            $0.trailing.equalTo(containerView).offset(-16)
            $0.centerY.equalTo(containerView)
        }
    }
    
    func bind(cellType: SettingCellType) {
        titleLabel.text = cellType.title
        descriptionLabel.text = cellType.description
        
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
