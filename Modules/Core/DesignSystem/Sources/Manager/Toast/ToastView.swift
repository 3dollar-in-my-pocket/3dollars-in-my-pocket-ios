import UIKit

final class ToastView: UIView {
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = DesignSystemAsset.Colors.gray95.color
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false

        return containerView
    }()

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        messageLabel.textColor = DesignSystemAsset.Colors.systemWhite.color
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        return messageLabel
    }()

    private var iconLeadingConstraint: NSLayoutConstraint?
    private var messageLeadingToIcon: NSLayoutConstraint?
    private var messageLeadingToContainer: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(message: String, icon: UIImage? = nil) {
        self.messageLabel.text = message

        if let icon {
            iconView.image = icon
            iconView.isHidden = false
            messageLeadingToContainer?.isActive = false
            messageLeadingToIcon?.isActive = true
        } else {
            iconView.image = nil
            iconView.isHidden = true
            messageLeadingToIcon?.isActive = false
            messageLeadingToContainer?.isActive = true
        }
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(messageLabel)
    }

    private func bindConstraints() {
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true

        let leadingToIcon = messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8)
        let leadingToContainer = messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)
        leadingToContainer.isActive = true

        self.messageLeadingToIcon = leadingToIcon
        self.messageLeadingToContainer = leadingToContainer
    }
}
