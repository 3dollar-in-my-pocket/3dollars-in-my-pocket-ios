import UIKit

public final class SearchField: UIView {
    public enum Layout {
        public static let height: CGFloat = 50
        static let horizontalPadding: CGFloat = 12
        static let spacing: CGFloat = 10
        static let iconSize: CGFloat = 24
        static let clearSize: CGFloat = 20
        static let cornerRadius: CGFloat = 12
        static let borderWidth: CGFloat = 1
    }

    public var leftIcon: UIImage? {
        get { leftIconView.image }
        set {
            leftIconView.image = newValue?.withRenderingMode(.alwaysTemplate)
            leftIconView.isHidden = newValue == nil
        }
    }

    public var placeholder: String? {
        get { textField.attributedPlaceholder?.string }
        set {
            textField.attributedPlaceholder = newValue.map {
                NSAttributedString(string: $0, attributes: [.foregroundColor: DesignSystemAsset.Colors.gray40.color])
            }
        }
    }

    public let textField: UITextField = {
        let textField = UITextField()
        textField.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        textField.textColor = DesignSystemAsset.Colors.gray100.color
        textField.tintColor = DesignSystemAsset.Colors.mainPink.color
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textField
    }()

    public let clearButton: UIButton = {
        let button = UIButton()
        button.setImage(DesignSystemAsset.Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = DesignSystemAsset.Colors.gray100.color
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let leftIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = DesignSystemAsset.Colors.gray100.color
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public init(leftIcon: UIImage? = nil, placeholder: String? = nil) {
        super.init(frame: .zero)

        self.leftIcon = leftIcon
        self.placeholder = placeholder
        setup()
        bindConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = DesignSystemAsset.Colors.systemWhite.color
        layer.cornerRadius = Layout.cornerRadius
        layer.borderWidth = Layout.borderWidth
        layer.borderColor = DesignSystemAsset.Colors.gray30.color.cgColor
        layer.masksToBounds = true
        addSubview(stackView)
        stackView.addArrangedSubview(leftIconView)
        stackView.addArrangedSubview(textField)
        stackView.addArrangedSubview(clearButton)
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Layout.height),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Layout.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Layout.horizontalPadding),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftIconView.widthAnchor.constraint(equalToConstant: Layout.iconSize),
            leftIconView.heightAnchor.constraint(equalToConstant: Layout.iconSize),
            clearButton.widthAnchor.constraint(equalToConstant: Layout.clearSize),
            clearButton.heightAnchor.constraint(equalToConstant: Layout.clearSize),
            textField.heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
    }
}
