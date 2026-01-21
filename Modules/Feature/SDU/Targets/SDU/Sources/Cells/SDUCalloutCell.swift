import UIKit

import Common
import DesignSystem
import Model
import SnapKit

public final class SDUCalloutCell: BaseCollectionViewCell {
    enum Layout {
        static let singleLineHeight: CGFloat = 90
        static let doubleLineHeight: CGFloat = 102
        static func height(viewModel: SDUCalloutCellViewModel) -> CGFloat {
            if viewModel.output.data.title.text.numberOfLines > 1 {
                return doubleLineHeight
            } else {
                return singleLineHeight
            }
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 16, left: 10, bottom: 16, right: 10)
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 20
        stackView.layer.masksToBounds = true
        stackView.spacing = 4
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.numberOfLines = 2
        label.textColor = Colors.gray60.color
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = Colors.gray60.color
        label.font = Fonts.medium.font(size: 12)
        label.textAlignment = .center
        return label
    }()

    public override func setup() {
        super.setup()

        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
    }

    public override func bindConstraints() {
        super.bindConstraints()

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    public func bind(_ viewModel: SDUCalloutCellViewModel) {
        let data = viewModel.output.data

        titleLabel.setSDText(data.title)
        titleLabel.setLineHeight(lineHeight: 24)

        if let description = data.description {
            descriptionLabel.setSDText(description)
            descriptionLabel.setLineHeight(lineHeight: 18)
        }

        stackView.setSDSurfaceStyle(data.style)
    }
}
