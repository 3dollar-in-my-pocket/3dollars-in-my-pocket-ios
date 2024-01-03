import UIKit

import Common
import DesignSystem
import Model

final class BossStoreFeedbacksCell: BaseCollectionViewCell {
    enum Layout {
        static func height(viewModel: BossStoreFeedbacksCellViewModel) -> CGFloat {
            var height: CGFloat = 24 + 12 // title
            let itemCount = CGFloat(viewModel.output.feedbacks.count)
            height += itemCount * BossStoreFeedbackItemView.Layout.height
            height += CGFloat(itemCount - 1) * itemSpacing
            height += contentInsets.top + contentInsets.bottom
            return height
        }

        static let itemSpacing: CGFloat = 16
        static let contentInsets: UIEdgeInsets = .init(top: 16, left: 0, bottom: 16, right: 0)
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = Strings.BossStoreDetail.Feedback.title
    }

    private let countLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 16)
        $0.textColor = Colors.gray100.color
    }

    private let sendFeedbackButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.setTitle(Strings.BossStoreDetail.Feedback.sendFeedback, for: .normal)
    }

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = Layout.itemSpacing
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.stackView.subviews.forEach { $0.removeFromSuperview() }
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            countLabel,
            sendFeedbackButton,
            containerView
        ])

        containerView.addSubview(stackView)
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(2)
            $0.centerY.equalTo(titleLabel)
        }

        sendFeedbackButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Layout.contentInsets.top)
            $0.leading.trailing.equalToSuperview()
        }
    }

    func bind(viewModel: BossStoreFeedbacksCellViewModel) {
        let feedbacks = viewModel.output.feedbacks

        for index in feedbacks.indices {
            let feedback = feedbacks[index]
            let itemView = self.generateStackItem(feedback: feedback, index: index)

            self.stackView.addArrangedSubview(itemView)
        }

        countLabel.text = "\(viewModel.output.feedbackTotalCount)개"

        sendFeedbackButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSendFeedbackButton)
            .store(in: &cancellables)
    }

    private func generateStackItem(feedback: FeedbackCountWithRatioResponse, index: Int) -> BossStoreFeedbackItemView {
        let itemView = BossStoreFeedbackItemView()
        itemView.bind(feedback: feedback, isTopRate: index < 3)
        return itemView
    }
}
