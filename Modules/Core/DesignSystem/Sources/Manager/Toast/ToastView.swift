import UIKit

final class ToastView: UIView {
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = DesignSystemAsset.Colors.gray95.color
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        return containerView
    }()
    
    private let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        messageLabel.textColor = DesignSystemAsset.Colors.systemWhite.color
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return messageLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(message: String) {
        self.messageLabel.text = message
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(containerView)
        addSubview(messageLabel)
    }
    
    private func bindConstraints() {
        messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        containerView.leftAnchor.constraint(equalTo: messageLabel.leftAnchor, constant: -16).isActive = true
        containerView.rightAnchor.constraint(equalTo: messageLabel.rightAnchor, constant: 16).isActive = true
        containerView.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
