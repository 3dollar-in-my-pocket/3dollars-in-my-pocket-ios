import UIKit

import Common
import DesignSystem
import SnapKit

final class StoreSectionEmptyView: UIView {
    enum Layout {
        static let height: CGFloat = 78
        static let iconSize: CGFloat = 48
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 2
        stackView.axis = .horizontal
        return stackView
    }()

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.empty02.image
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray50.color
        return label
    }()

    init(text: String) {
        super.init(frame: .zero)
        backgroundColor = Colors.gray10.color
        layer.cornerRadius = 6
        titleLabel.text = text

        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(titleLabel)
        addSubview(stackView)

        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        emptyImageView.snp.makeConstraints {
            $0.size.equalTo(Layout.iconSize)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
