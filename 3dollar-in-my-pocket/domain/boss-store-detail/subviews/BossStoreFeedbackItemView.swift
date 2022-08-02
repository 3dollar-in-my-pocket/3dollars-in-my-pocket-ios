import UIKit

import Base

final class BossStoreFeedbackItemView: Base.BaseView {
    static let height: CGFloat = 50
    
    private let titleLabel = UILabel().then {
        $0.font = .bold(size: 14)
        $0.textColor = R.color.gray95()
        $0.text = "🍕 음식이 맛있어요"
    }
    
    private let countLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = .regular(size: 12)
        $0.textColor = .green
        $0.layer.borderColor = R.color.green()?.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 11
    }
    
    private let progressBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(r: 242, g: 251, b: 247)
        $0.layer.cornerRadius = 8
    }
    
    private let progressView = UIProgressView().then {
        $0.progressTintColor = R.color.green()
        $0.layer.cornerRadius = 4
        $0.trackTintColor = .clear
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews([
            self.titleLabel,
            self.countLabel,
            self.progressBackgroundView,
            self.progressView
        ])
    }
    
    override func bindConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(self.countLabel).offset(2)
        }
        
        self.countLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-24)
        }
        
        self.progressBackgroundView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(16)
            make.bottom.equalToSuperview()
        }
        
        self.progressView.snp.makeConstraints { make in
            make.left.equalTo(self.progressBackgroundView).offset(4)
            make.top.equalTo(self.progressBackgroundView).offset(4)
            make.right.equalTo(self.progressBackgroundView).offset(-4)
            make.bottom.equalTo(self.progressBackgroundView).offset(-4)
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(Self.height)
        }
    }
    
    func bind(feedback: BossStoreFeedback, isTopRate: Bool) {
//        self.titleLabel.text = "\(feedback.type.emoji) \(statistics.type.description)"
        self.countLabel.text = "\(feedback.count)개"
        self.progressView.progress = Float(feedback.ratio)
        self.setProgressBar(isTopRate: isTopRate)
    }
    
    private func setProgressBar(isTopRate: Bool) {
        self.progressBackgroundView.backgroundColor
        = isTopRate ? UIColor(r: 242, g: 251, b: 247) : R.color.gray5()
        self.progressView.progressTintColor
        = isTopRate ? R.color.green() : R.color.gray10()
    }
}
