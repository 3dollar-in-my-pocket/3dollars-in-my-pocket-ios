import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreEditCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        onAction = nil
    }

    override func setup() {
        contentView.addSubview(stackView)
    }

    override func bindConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(44)
        }
    }

    func bind(_ section: StoreEditSection) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.actionBars.forEach { actionBar in
            let button = UIButton(type: .system)
            button.titleLabel?.font = Fonts.medium.font(size: 13)
            button.setSDButton(actionBar.button)
            if let action = actionBar.storeSectionAction {
                button.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
            }
            stackView.addArrangedSubview(button)
        }
    }
}
