import UIKit

public final class SelectRow: UIView {
    public enum Layout {
        public static let height: CGFloat = 44
        static let horizontalPadding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let checkSize: CGFloat = 20
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
    }

    public var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    public var isSelected: Bool = false {
        didSet {
            applySelected()
        }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.Icons.check.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = DesignSystemAsset.Colors.mainRed.color
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    public init(title: String? = nil, isSelected: Bool = false) {
        self.isSelected = isSelected
        super.init(frame: .zero)

        titleLabel.text = title
        setup()
        bindConstraints()
        applySelected()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = Layout.borderWidth
        layer.masksToBounds = true
        isUserInteractionEnabled = false
        addSubview(titleLabel)
        addSubview(checkImageView)
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalPadding),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: checkImageView.leadingAnchor,
                constant: -Layout.spacing
            ),
            checkImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalPadding),
            checkImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: Layout.checkSize),
            checkImageView.heightAnchor.constraint(equalToConstant: Layout.checkSize)
        ])
    }

    private func applySelected() {
        layer.borderColor = isSelected
            ? DesignSystemAsset.Colors.mainRed.color.cgColor
            : DesignSystemAsset.Colors.gray40.color.cgColor
        titleLabel.textColor = isSelected
            ? DesignSystemAsset.Colors.gray100.color
            : DesignSystemAsset.Colors.gray60.color
        checkImageView.isHidden = !isSelected
    }
}
