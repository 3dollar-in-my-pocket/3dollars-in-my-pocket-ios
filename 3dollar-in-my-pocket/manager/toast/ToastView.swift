import UIKit

final class ToastView: BaseView {
    private let containerView = UIView().then {
        $0.backgroundColor = R.color.green()
        $0.layer.cornerRadius = 20
    }
    
    private let messageLabel = UILabel().then {
        $0.font = .medium(size: 14)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.containerView,
            self.messageLabel
        ])
    }
    
    override func bindConstraints() {
        self.messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.containerView.snp.makeConstraints { make in
            make.left.equalTo(self.messageLabel).offset(-16)
            make.right.equalTo(self.messageLabel).offset(16)
            make.centerY.equalTo(self.messageLabel)
            make.height.equalTo(40)
        }
        
        self.snp.makeConstraints { make in
            make.edges.equalTo(containerView).priority(.high)
        }
    }
    
    func bind(message: String) {
        self.messageLabel.text = message
    }
}
