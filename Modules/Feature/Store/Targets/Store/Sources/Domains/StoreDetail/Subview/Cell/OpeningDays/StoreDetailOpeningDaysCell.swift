import UIKit

import Common
import DesignSystem
import Model

final class StoreDetailOpeningDaysCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 524
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()

        stackView.subviews.forEach { $0.removeFromSuperview() }
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            titleLabel,
            containerView
        ])

        containerView.addSubview(stackView)
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-32)
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    func bind(viewModel: StoreDetailOpeningDaysCellViewModel) {
        titleLabel.setSDText(viewModel.output.title)
        setStackView(openingDays: viewModel.output.openingDays)
    }
    
    private func setStackView(openingDays: [StoreOpeningDaysSectionResponse.StoreOpeningDaySectionResponse]) {
        for openingDay in openingDays {
            let stackViewItem = generateStackItemView(
                openingDay: openingDay,
                isLast: openingDay == openingDays.last
            )

            stackView.addArrangedSubview(stackViewItem)
        }
    }

    private func generateStackItemView(
        openingDay: StoreOpeningDaysSectionResponse.StoreOpeningDaySectionResponse,
        isLast: Bool
    ) -> StoreDetailOpeningDayItemView {
        let stackItemView = StoreDetailOpeningDayItemView()
        stackItemView.bind(openingDay: openingDay, isLast: isLast)
        return stackItemView
    }
}
