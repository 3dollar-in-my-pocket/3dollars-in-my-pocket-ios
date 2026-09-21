import UIKit

import Common
import DesignSystem

import SnapKit

final class StoreIdDebugView: UIView {
    enum Layout {
        static let height: CGFloat = 36
        static let horizontalPadding: CGFloat = 12
    }

    var onCopy: ((String) -> Void)?

    private var storeId: String = ""

    private let idLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.medium.font(size: 12)
        return label
    }()

    private let copyButton: UIButton = {
        let button = UIButton()
        button.setTitle("복사", for: .normal)
        button.setTitleColor(Colors.systemWhite.color, for: .normal)
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.backgroundColor = Colors.mainPink.color
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        bindConstraints()
    }

    required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = Colors.gray100.color.withAlphaComponent(0.85)
        layer.cornerRadius = Layout.height / 2
        clipsToBounds = true
        addSubViews([idLabel, copyButton])
        copyButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            onCopy?(storeId)
        }, for: .touchUpInside)
    }

    private func bindConstraints() {
        snp.makeConstraints { $0.height.equalTo(Layout.height) }

        idLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.horizontalPadding)
            $0.centerY.equalToSuperview()
        }

        copyButton.snp.makeConstraints {
            $0.leading.equalTo(idLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-Layout.horizontalPadding)
            $0.centerY.equalToSuperview()
        }
    }

    func bind(storeId: Int) {
        self.storeId = String(storeId)
        idLabel.text = "가게 ID \(storeId)"
    }
}
