import UIKit

import Common
import DesignSystem
import Model
import SnapKit

final class StoreCTACell: BaseCollectionViewCell {
    enum Layout {
        static let horizontalMargin: CGFloat = 20
        static let verticalMargin: CGFloat = 16
    }

    var onAction: ((StoreSectionAction) -> Void)?
    private let titleLabel = StoreSectionTextLabel(font: Fonts.semiBold.font(size: 14))
    private let subtitleLabel = StoreSectionTextLabel(font: Fonts.medium.font(size: 12))

    private let footerLeftButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.imagePadding = 4
        let button = UIButton(configuration: config)
        button.titleLabel?.font = Fonts.medium.font(size: 12)
        return button
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        footerLeftButton.clear()
        onAction = nil
    }

    override func setup() {
        contentView.addSubViews([titleLabel, subtitleLabel, footerLeftButton])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.verticalMargin)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Layout.horizontalMargin)
        }
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(titleLabel)
        }
        footerLeftButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(Layout.horizontalMargin)
            $0.bottom.equalToSuperview().offset(-Layout.verticalMargin)
        }
    }

    func bind(_ section: StoreCTASection) {
        titleLabel.setSDText(section.content.title)
        subtitleLabel.setSDText(section.content.subTitle)
        subtitleLabel.isHidden = section.content.subTitle == nil
        footerLeftButton.setOptionalSDButton(section.content.footerLeftButton)
        footerLeftButton.removeTarget(nil, action: nil, for: .touchUpInside)
        if let action = section.content.footerLeftButton?.storeSectionAction {
            footerLeftButton.addAction(UIAction { [weak self] _ in self?.onAction?(action) }, for: .touchUpInside)
        }
    }
}
