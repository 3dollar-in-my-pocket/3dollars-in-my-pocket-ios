import UIKit
import Common
import DesignSystem
import Model

final class BossStoreFeedbackItemView: BaseView {
    static let height: CGFloat = 50

    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 14)
        $0.textColor = Colors.gray100.color
    }

    private let countLabel = PaddingLabel(
        topInset: 4,
        bottomInset: 4,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.mainPink.color
        $0.layer.borderColor = Colors.mainPink.color.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 11
    }

    private let progressBackgroundView = UIView().then {
        $0.backgroundColor = Colors.pink100.color
        $0.layer.cornerRadius = 8
    }

    private let progressView = UIProgressView().then {
        $0.progressTintColor = Colors.mainPink.color
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
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(self.countLabel).offset(2)
        }

        self.countLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
        }

        self.progressBackgroundView.snp.makeConstraints { make in
            make.leading.equalTo(self.titleLabel)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(16)
            make.bottom.equalToSuperview()
        }

        self.progressView.snp.makeConstraints { make in
            make.leading.equalTo(self.progressBackgroundView).offset(4)
            make.top.equalTo(self.progressBackgroundView).offset(4)
            make.trailing.equalTo(self.progressBackgroundView).offset(-4)
            make.bottom.equalTo(self.progressBackgroundView).offset(-4)
        }

        self.snp.makeConstraints { make in
            make.height.equalTo(Self.height)
        }
    }

    func bind(feedback: FeedbackCountWithRatioResponse, isTopRate: Bool) {
        self.titleLabel.text = "\(feedback.feedbackType.emoji) \(feedback.feedbackType.description)"
        self.countLabel.text = "\(feedback.count)개"
        self.progressView.progress = Float(feedback.ratio)
        self.setProgressBar(isTopRate: feedback.count == 0 ? false : isTopRate)
    }

    private func setProgressBar(isTopRate: Bool) {
        self.progressBackgroundView.backgroundColor
        = isTopRate ? Colors.pink100.color : Colors.gray10.color
        self.progressView.progressTintColor
        = isTopRate ? Colors.mainPink.color : Colors.gray30.color
    }
}
