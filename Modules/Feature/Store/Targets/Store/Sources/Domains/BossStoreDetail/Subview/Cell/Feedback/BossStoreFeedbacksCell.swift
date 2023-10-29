import UIKit

import Common
import DesignSystem
import Model

final class BossStoreFeedbacksCell: BaseCollectionViewCell {
    enum Layout {
        static func height(viewModel: BossStoreFeedbacksCellViewModel) -> CGFloat {
            return 12 + 24 + CGFloat(viewModel.output.feedbacks.count * (50 + 16))
        }
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = "가게 평가"
    }

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.stackView.subviews.forEach { $0.removeFromSuperview() }
    }

    override func setup() {
        contentView.addSubViews([
            titleLabel,
            containerView
        ])

        containerView.addSubview(stackView)
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func bind(viewModel: BossStoreFeedbacksCellViewModel) {
        let feedbacks = viewModel.output.feedbacks

        for index in feedbacks.indices {
            let feedback = feedbacks[index]
            let itemView = self.generateStackItem(feedback: feedback, index: index)

            self.stackView.addArrangedSubview(itemView)
        }
    }

    private func generateStackItem(
        feedback: FeedbackCountWithRatioResponse,
        index: Int
    ) -> BossStoreFeedbackItemView {
        let itemView = BossStoreFeedbackItemView()

        itemView.bind(feedback: feedback, isTopRate: index < 3)
        return itemView
    }
}
