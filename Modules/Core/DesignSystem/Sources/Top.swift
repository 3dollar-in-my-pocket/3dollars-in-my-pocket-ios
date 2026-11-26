import UIKit

public final class Top: UIView {
    public enum Theme {
        case light
        case dark

        var backgroundColor: UIColor {
            switch self {
            case .light:
                return DesignSystemAsset.Colors.systemWhite.color
            case .dark:
                return DesignSystemAsset.Colors.gray100.color
            }
        }

        var contentColor: UIColor {
            switch self {
            case .light:
                return DesignSystemAsset.Colors.gray100.color
            case .dark:
                return DesignSystemAsset.Colors.systemWhite.color
            }
        }
    }

    public enum Layout {
        public static let height: CGFloat = 56
        static let sideWidth: CGFloat = 72
        static let horizontalPadding: CGFloat = 16
        static let iconSize: CGFloat = 24
        static let rightSpacing: CGFloat = 8
    }

    public var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }

    public let backButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .init(
            top: Layout.horizontalPadding,
            leading: Layout.horizontalPadding,
            bottom: Layout.horizontalPadding,
            trailing: Layout.horizontalPadding
        )
        configuration.image = DesignSystemAsset.Icons.chevronLeft.image
            .resized(to: Layout.iconSize)
            .withRenderingMode(.alwaysTemplate)
        let button = UIButton(configuration: configuration)
        button.tintAdjustmentMode = .normal
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.rightSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public init(
        theme: Theme = .light,
        title: String? = nil,
        showsBackButton: Bool = true,
        rightButtons: [UIButton] = []
    ) {
        super.init(frame: .zero)

        backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.contentColor
        backButton.tintColor = theme.contentColor
        backButton.isHidden = showsBackButton == false
        titleLabel.text = title
        rightButtons.forEach { rightStackView.addArrangedSubview($0) }

        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(rightStackView)
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Layout.sideWidth),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Layout.sideWidth),
            rightStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalPadding),
            rightStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

private extension UIImage {
    func resized(to width: CGFloat) -> UIImage {
        let scale = width / size.width
        let targetSize = CGSize(width: width, height: size.height * scale)
        return UIGraphicsImageRenderer(size: targetSize).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
