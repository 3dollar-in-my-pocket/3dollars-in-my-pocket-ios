import UIKit
import Combine

import Common

final class WriteCompleteAdditionalButton: BaseView {
    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView = UIImageView()
    
    private let checkImageView: UIImageView = {
        let imageView = UIImageView(image: WriteAsset.iconGreenCheck.image)
        imageView.isHidden = true
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 14)
        titleLabel.textColor = Colors.gray100.color
        return titleLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.medium.font(size: 12)
        descriptionLabel.textColor = Colors.gray60.color
        return descriptionLabel
    }()
    
    let tapPublisher = PassthroughSubject<Void, Never>()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    init(icon: UIImage, title: String, description: String) {
        super.init(frame: .zero)
        
        iconImageView.image = icon
        titleLabel.text = title
        descriptionLabel.text = description
        
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(isChecked: Bool) {
        let description = isChecked ? "작성 완료" : descriptionLabel.text
        descriptionLabel.text = description
        descriptionLabel.textColor = isChecked ? Colors.mainGreen.color : Colors.gray60.color
        iconContainer.backgroundColor = isChecked ? Colors.green200.color : Colors.gray10.color
        checkImageView.isHidden = !isChecked
        isUserInteractionEnabled = isChecked.isNot
    }
    
    private func setupUI() {
        backgroundColor = Colors.systemWhite.color
        layer.cornerRadius = 16
        layer.shadowColor = Colors.systemBlack.color.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.1
        
        addSubViews([
            iconContainer,
            checkImageView,
            titleLabel,
            descriptionLabel
        ])
        iconContainer.addSubview(iconImageView)
        
        iconContainer.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.top.equalToSuperview().offset(12)
            $0.size.equalTo(32)
        }
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.center.equalToSuperview()
        }
        
        checkImageView.snp.makeConstraints {
            $0.trailing.equalTo(iconContainer).offset(5)
            $0.top.equalTo(iconContainer).offset(-3)
            $0.size.equalTo(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(iconContainer.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.equalTo(titleLabel)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(66)
        }
    }
    
    private func bind() {
        addGestureRecognizer(tapGestureRecognizer)
        isUserInteractionEnabled = true
        tapGestureRecognizer.tapPublisher
            .map { _ in () }
            .subscribe(tapPublisher)
            .store(in: &cancellables)
    }
}
