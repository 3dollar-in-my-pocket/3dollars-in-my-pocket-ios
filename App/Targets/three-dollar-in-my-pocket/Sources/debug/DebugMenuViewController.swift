import UIKit

import Common
import DesignSystem

import SnapKit

final class DebugMenuViewController: BaseViewController {
    var items: [DebugMenuItem] = []
    var onSelectItem: ((DebugMenuItem) -> Void)?

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


    private let gaLogRecordingRow = DebugMenuToggleRow(
        title: "GA 로그 기록",
        description: "앱이 보내는 GA 로그와 직전 탭(요소·화면 캡처)을 기록합니다. 끄면 기록·알림이 모두 멈춥니다"
    )

    private let gaLogToastRow = DebugMenuToggleRow(
        title: "GA 로그 실시간 알림",
        description: "로그가 나갈 때 화면 상단에 0.3초 단위로 묶어 보여줍니다"
    )

    private let gaLogImpressionToastRow = DebugMenuToggleRow(
        title: "GA 로그 알림에 impression 포함",
        description: "스크롤 중 노출 로그까지 알림에 띄웁니다 (뷰어에는 항상 기록)"
    )

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
        stackView.addArrangedSubview(gaLogRecordingRow)
        stackView.addArrangedSubview(gaLogToastRow)
        stackView.addArrangedSubview(gaLogImpressionToastRow)
        items.forEach { item in
            let row = DebugMenuLinkRow(title: item.title)
            row.onTap = { [weak self] in
                self?.select(item)
            }
            stackView.addArrangedSubview(row)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }

        storeIdRow.isOn = Preference.shared.isShowStoreIdDebugView
        gaLogRecordingRow.isOn = GALogStore.shared.isRecordingEnabled
        gaLogToastRow.isOn = GALogStore.shared.isToastEnabled
        gaLogImpressionToastRow.isOn = GALogStore.shared.isImpressionToastEnabled
        updateGALogToggleAvailability()
    }

    override func bindEvent() {
        storeIdRow.onChange = { isOn in
            Preference.shared.isShowStoreIdDebugView = isOn
        }
        gaLogRecordingRow.onChange = { [weak self] isOn in
            GALogStore.shared.isRecordingEnabled = isOn
            self?.updateGALogToggleAvailability()
        }
        gaLogToastRow.onChange = { [weak self] isOn in
            GALogStore.shared.isToastEnabled = isOn
            self?.updateGALogToggleAvailability()
        }
        gaLogImpressionToastRow.onChange = { isOn in
            GALogStore.shared.isImpressionToastEnabled = isOn
        }
    }

    private func updateGALogToggleAvailability() {
        let isRecordingEnabled = GALogStore.shared.isRecordingEnabled
        gaLogToastRow.isEnabled = isRecordingEnabled
        gaLogImpressionToastRow.isEnabled = isRecordingEnabled && GALogStore.shared.isToastEnabled
    }

    private func select(_ item: DebugMenuItem) {
        dismiss(animated: true) { [weak self] in
            self?.onSelectItem?(item)
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

    var isEnabled: Bool {
        get { switchButton.isEnabled }
        set {
            switchButton.isEnabled = newValue
            alpha = newValue ? 1 : 0.4
        }
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

    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

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

    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
