import UIKit

final class BossStoreFeedbackTableViewCell: BaseTableViewCell {
    static let registerId = "\(BossStoreFeedbackTableViewCell.self)"
    static let height: CGFloat = 60
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 24
        $0.layer.borderColor = Color.gray10?.cgColor
        $0.layer.borderWidth = 1
        $0.backgroundColor = .white
    }
    
    private let checkImage = UIImageView()
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = Color.gray95
    }
    
    override func setup() {
        self.selectionStyle = .none
        self.addSubViews([
            self.containerView,
            self.checkImage,
            self.titleLabel
        ])
    }
    
    override func bindConstraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        self.checkImage.snp.makeConstraints { make in
            make.left.equalTo(self.containerView).offset(14)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalTo(self.containerView)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.checkImage)
            make.left.equalTo(self.checkImage.snp.right).offset(24)
            make.right.equalTo(self.containerView).offset(-24)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.containerView.backgroundColor = UIColor(r: 242, g: 251, b: 247)
            self.containerView.layer.borderColor = Color.green?.cgColor
            self.checkImage.image = UIImage(named: "ic_check_on_green")
        } else {
            self.containerView.backgroundColor = .white
            self.containerView.layer.borderColor = Color.gray10?.cgColor
            self.checkImage.image = UIImage(named: "ic_check_off_green")
        }
        super.setSelected(selected, animated: animated)
    }
    
    func bind(feedbackType: BossStoreFeedbackMeta) {
        self.titleLabel.text = "\(feedbackType.emoji) \(feedbackType.description)"
    }
}
