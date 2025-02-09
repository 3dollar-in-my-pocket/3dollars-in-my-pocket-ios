import UIKit
import Common
import DesignSystem
import Model

final class BossStoreFeedbackItemView: BaseView {
    enum Layout {
        static let height: CGFloat = 50
    }

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
        super.setup()

        backgroundColor = .clear

        addSubViews([
            titleLabel,
            countLabel,
            progressBackgroundView,
            progressView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalTo(self.countLabel).offset(2)
        }

        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-24)
        }

        progressBackgroundView.snp.makeConstraints {
            $0.leading.equalTo(self.titleLabel)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview()
        }

        progressView.snp.makeConstraints {
            $0.leading.equalTo(self.progressBackgroundView).offset(4)
            $0.top.equalTo(self.progressBackgroundView).offset(4)
            $0.trailing.equalTo(self.progressBackgroundView).offset(-4)
            $0.bottom.equalTo(self.progressBackgroundView).offset(-4)
        }

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }

    func bind(feedback: FeedbackCountWithRatioResponse, isTopRate: Bool) {
        titleLabel.text = "\(feedback.feedbackType.emoji) \(feedback.feedbackType.description)"
        countLabel.text = "\(feedback.count)개"
        progressView.progress = Float(feedback.ratio)
        setProgressBar(isTopRate: feedback.count == 0 ? false : isTopRate)
    }

    private func setProgressBar(isTopRate: Bool) {
        progressBackgroundView.backgroundColor = isTopRate ? Colors.pink100.color : Colors.gray10.color
        progressView.progressTintColor = isTopRate ? Colors.mainPink.color : Colors.gray30.color
    }
}
