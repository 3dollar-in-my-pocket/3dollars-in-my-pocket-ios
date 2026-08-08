import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreCTACell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.pink100.color
        view.layer.cornerRadius = 12
        return view
    }()
    private let titleLabel = StoreSectionTextLabel(font: Fonts.bold.font(size: 16))
    private let subtitleLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
    private let button = UIButton(type: .system)

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
    }

    override func setup() {
        containerView.addSubViews([titleLabel, subtitleLabel, button])
        contentView.addSubview(containerView)
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview().inset(16); $0.trailing.lessThanOrEqualTo(button.snp.leading).offset(-8) }
        subtitleLabel.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(4); $0.leading.equalToSuperview().inset(16); $0.bottom.equalToSuperview().inset(16) }
        button.snp.makeConstraints { $0.trailing.equalToSuperview().inset(16); $0.centerY.equalToSuperview() }
    }

    func bind(_ section: StoreCTASection) {
        titleLabel.setSDText(section.content.title)
        subtitleLabel.setSDText(section.content.subTitle)
        subtitleLabel.isHidden = section.content.subTitle == nil
        button.setOptionalSDButton(section.content.footerLeftButton)
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.content.footerLeftButton?.storeSectionAction {
            button.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}
