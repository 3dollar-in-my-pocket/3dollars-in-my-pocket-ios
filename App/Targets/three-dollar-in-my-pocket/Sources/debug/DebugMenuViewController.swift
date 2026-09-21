import UIKit

import Common
import DesignSystem

import SnapKit

/// 디버깅 플로팅 버튼을 눌렀을 때 뜨는 메뉴 바텀시트.
/// 개발 환경에서만 진입할 수 있으므로 현지화하지 않는다.
final class DebugMenuViewController: BaseViewController {
    /// "네트워크 보기" 를 눌렀을 때 실행할 동작. netfox 호출은 호스트가 넘겨준다.
    var onSelectNetworkLog: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "디버깅 메뉴"
        label.font = Fonts.bold.font(size: 18)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let storeIdRow = DebugMenuToggleRow(
        title: "가게 상세 진입 시 ID 노출",
        description: "가게 상세에 가게 ID 플로팅 뷰를 띄웁니다"
    )

    private let networkRow = DebugMenuLinkRow(title: "네트워크 보기")

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        stackView.addArrangedSubview(storeIdRow)
        stackView.addArrangedSubview(networkRow)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }

        storeIdRow.isOn = Preference.shared.isShowStoreIdDebugView
    }

    override func bindEvent() {
        storeIdRow.onChange = { isOn in
            Preference.shared.isShowStoreIdDebugView = isOn
        }

        networkRow.onTap = { [weak self] in
            guard let self else { return }
            // 시트를 먼저 닫아야 netfox 화면이 가려지지 않는다.
            dismiss(animated: true) { [weak self] in
                self?.onSelectNetworkLog?()
            }
        }
    }
}

// MARK: Rows
private final class DebugMenuToggleRow: UIView {
    var onChange: ((Bool) -> Void)?

    var isOn: Bool {
        get { switchButton.isOn }
        set { switchButton.isOn = newValue }
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 15)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 12)
        label.textColor = Colors.gray50.color
        label.numberOfLines = 0
        return label
    }()

    private let switchButton: UISwitch = {
        let button = UISwitch()
        button.onTintColor = Colors.mainPink.color
        return button
    }()

    init(title: String, description: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        descriptionLabel.text = description
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        addSubview(stackView)
        addSubview(switchButton)

        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(switchButton.snp.leading).offset(-12)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
        }

        switchButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        switchButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onChange?(switchButton.isOn)
        }, for: .valueChanged)
    }
}

private final class DebugMenuLinkRow: UIView {
    var onTap: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 15)
        label.textColor = Colors.gray100.color
        return label
    }()

    private let arrowLabel: UILabel = {
        let label = UILabel()
        label.text = ">"
        label.font = Fonts.medium.font(size: 15)
        label.textColor = Colors.gray50.color
        return label
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        addSubview(titleLabel)
        addSubview(arrowLabel)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }

        arrowLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    @objc private func didTap() {
        onTap?()
    }
}
