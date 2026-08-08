import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreCalloutCell: BaseCollectionViewCell {
    var onAction: ((StoreSectionAction) -> Void)?
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.backgroundColor = Colors.gray10.color
        return view
    }()
    private let titleLabel = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 14))
    private let subTitleLabel = StoreSectionTextLabel(font: Fonts.regular.font(size: 13))
    private let footerButton = UIButton(type: .system)

    override func prepareForReuse() {
        super.prepareForReuse()
        onAction = nil
    }

    override func setup() {
        containerView.addSubViews([titleLabel, subTitleLabel, footerButton])
        contentView.addSubview(containerView)
    }

    override func bindConstraints() {
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(12)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        footerButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(12)
        }
    }

    func bind(_ section: StoreCalloutSection) {
        titleLabel.setSDText(section.content.title)
        subTitleLabel.setSDText(section.content.subTitle)
        subTitleLabel.isHidden = section.content.subTitle == nil
        footerButton.setOptionalSDButton(section.content.footerLeftButton)
        footerButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.content.footerLeftButton?.storeSectionAction {
            footerButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}
