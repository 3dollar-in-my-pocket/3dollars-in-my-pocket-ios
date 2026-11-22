import UIKit

public final class TextField: UIView {
    public enum State {
        case normal
        case focused
        case error
    }

    public enum Layout {
        public static let fieldHeight: CGFloat = 44
        static let titleHeight: CGFloat = 20
        static let helperHeight: CGFloat = 18
        static let spacing: CGFloat = 7
        static let horizontalPadding: CGFloat = 12
        static let suffixSpacing: CGFloat = 10
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
    }

    public var title: String? {
        get { titleLabel.text }
        set {
            titleLabel.text = newValue
            titleLabel.isHidden = newValue == nil
        }
    }

    public var placeholder: String? {
        get { textField.attributedPlaceholder?.string }
        set {
            textField.attributedPlaceholder = newValue.map {
                NSAttributedString(string: $0, attributes: [.foregroundColor: DesignSystemAsset.Colors.gray50.color])
            }
        }
    }

    public var suffix: String? {
        get { suffixLabel.text }
        set {
            suffixLabel.text = newValue
            suffixLabel.isHidden = newValue == nil
        }
    }

    public var helperText: String? {
        get { helperLabel.text }
        set {
            helperLabel.text = newValue
            helperLabel.isHidden = newValue == nil
        }
    }

    public var state: State = .normal {
        didSet {
            applyState()
        }
    }

    public let textField: UITextField = {
        let textField = UITextField()
        textField.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        textField.textColor = DesignSystemAsset.Colors.gray90.color
        textField.tintColor = DesignSystemAsset.Colors.mainPink.color
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textField
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 14)
        label.textColor = DesignSystemAsset.Colors.gray100.color
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let fieldView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.Colors.gray10.color
        view.layer.cornerRadius = Layout.cornerRadius
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let fieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Layout.suffixSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let suffixLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textColor = DesignSystemAsset.Colors.gray70.color
        label.isHidden = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let helperLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public init(title: String? = nil, placeholder: String? = nil, suffix: String? = nil) {
        super.init(frame: .zero)

        self.title = title
        self.placeholder = placeholder
        self.suffix = suffix
        setup()
        bindConstraints()
        applyState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(fieldView)
        stackView.addArrangedSubview(helperLabel)
        fieldView.addSubview(fieldStackView)
        fieldStackView.addArrangedSubview(textField)
        fieldStackView.addArrangedSubview(suffixLabel)

        textField.addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
    }

    private func bindConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        let bottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            bottomConstraint,
            titleLabel.heightAnchor.constraint(equalToConstant: Layout.titleHeight),
            fieldView.heightAnchor.constraint(equalToConstant: Layout.fieldHeight),
            helperLabel.heightAnchor.constraint(equalToConstant: Layout.helperHeight),
            fieldStackView.leadingAnchor.constraint(equalTo: fieldView.leadingAnchor, constant: Layout.horizontalPadding),
            fieldStackView.trailingAnchor.constraint(equalTo: fieldView.trailingAnchor, constant: -Layout.horizontalPadding),
            fieldStackView.topAnchor.constraint(equalTo: fieldView.topAnchor),
            fieldStackView.bottomAnchor.constraint(equalTo: fieldView.bottomAnchor),
            textField.heightAnchor.constraint(equalTo: fieldStackView.heightAnchor)
        ])
    }

    @objc private func didBeginEditing() {
        state = .focused
    }

    @objc private func didEndEditing() {
        state = .normal
    }

    private func applyState() {
        switch state {
        case .normal:
            fieldView.layer.borderWidth = 0
            fieldView.layer.borderColor = nil
            helperLabel.textColor = DesignSystemAsset.Colors.gray50.color

        case .focused:
            fieldView.layer.borderWidth = Layout.borderWidth
            fieldView.layer.borderColor = DesignSystemAsset.Colors.mainPink.color.cgColor
            helperLabel.textColor = DesignSystemAsset.Colors.gray50.color

        case .error:
            fieldView.layer.borderWidth = Layout.borderWidth
            fieldView.layer.borderColor = DesignSystemAsset.Colors.mainRed.color.cgColor
            helperLabel.textColor = DesignSystemAsset.Colors.mainRed.color
        }
    }
}
