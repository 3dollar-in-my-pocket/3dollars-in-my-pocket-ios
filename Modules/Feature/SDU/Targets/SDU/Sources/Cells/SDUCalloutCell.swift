import UIKit

import Common
import DesignSystem
import Model
import SnapKit

public final class SDUCalloutCell: BaseCollectionViewCell {
    enum Layout {
        static func height(data: CalloutCard) -> CGFloat {
            var height: CGFloat = 90
            
            if data.promptTitle.spans.first?.text.numberOfLines ?? 0 > 1 {
                height = 102
            }
            
            return height
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 16, left: 10, bottom: 16, right: 10)
        stackView.axis = .vertical
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

    public func bind(_ data: CalloutCard) {
        if let title = data.promptTitle.spans.first {
            titleLabel.setSDText(title)
        }

        if let description = data.description.spans.first {
            descriptionLabel.setSDText(description)
        }

        contentView.setSDSurfaceStyle(data.style)
    }
}
