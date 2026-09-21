import UIKit

import Common
import DesignSystem

import SnapKit

/// 디버깅용으로 가게 상세 위에 떠서 현재 가게 ID를 보여주는 플로팅 뷰.
///
/// 개발 환경에서 설정 > "[디버그] 가게 ID 표시" 를 켰을 때만 붙는다.
/// 프로덕션 빌드에서는 `AppEnvironment.isDebugToolAvailable` 이 false 라 절대 생성되지 않는다.
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

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
