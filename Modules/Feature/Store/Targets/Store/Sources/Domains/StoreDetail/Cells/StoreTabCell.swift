import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreTabCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 4
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
            $0.height.equalTo(40)
        }
    }

    func bind(_ section: StoreTabSection) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        section.tabs.forEach { tab in
            let button = UIButton(type: .system)
            button.titleLabel?.font = Fonts.medium.font(size: 13)
            button.setSDButton(tab.button)
            if let action = tab.storeSectionAction {
                button.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
            }
            stackView.addArrangedSubview(button)
        }
    }
}
