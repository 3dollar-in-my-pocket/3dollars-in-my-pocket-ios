import UIKit

final class BossStoreFeedbackHeaderView: UITableViewHeaderFooterView {
    static let registerId = "\(BossStoreFeedbackHeaderView.self)"
    static let height: CGFloat = 148
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 30)
        $0.textColor = Color.gray95
        $0.text = "boss_store_feedback_header_title".localized
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .bold(size: 12)
        $0.textColor = Color.green
        $0.text = "boss_store_feedback_header_description".localized
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setup()
        self.bindConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        self.addSubViews([
            self.titleLabel,
            self.descriptionLabel
        ])
    }
    
    private func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        self.descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16)
        }
    }
}
