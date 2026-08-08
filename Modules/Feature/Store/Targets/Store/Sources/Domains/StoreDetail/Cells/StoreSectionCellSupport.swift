import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// v2 섹션 셀에서 서버 텍스트와 칩을 반복 표시하기 위한 최소 공용 뷰.
final class StoreSectionTextLabel: UILabel {
    init(font: UIFont) {
        super.init(frame: .zero)
        self.font = font
        numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class StoreSectionFlowStackView: UIStackView {
    init(spacing: CGFloat) {
        super.init(frame: .zero)
        axis = .vertical
        alignment = .leading
        distribution = .fill
        self.spacing = spacing
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ chips: [SDChip]) {
        removeAll()
        chips.forEach { chip in
            let label = StoreSectionTextLabel(font: Fonts.medium.font(size: 13))
            label.setSDChip(chip)
            if let style = chip.style {
                label.layer.cornerRadius = 8
                label.layer.masksToBounds = true
                label.setSDChipStyle(style)
            }
            addArrangedSubview(label)
        }
    }

    func removeAll() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

extension UIButton {
    func setOptionalSDButton(_ button: SDButton?) {
        guard let button else {
            isHidden = true
            return
        }
        isHidden = false
        setSDButton(button)
    }
}

extension SDButton {
    var storeSectionAction: StoreSectionAction? {
        if let customAction {
            return .custom(customAction, clickLog: clickLog)
        }
        if let link {
            return .link(link, clickLog: clickLog)
        }
        return nil
    }
}

extension SDActionBar {
    var storeSectionAction: StoreSectionAction? {
        if let customAction = button.customAction {
            return .custom(customAction, clickLog: clickLog ?? button.clickLog)
        }
        if let link = button.link {
            return .link(link, clickLog: clickLog ?? button.clickLog)
        }
        return nil
    }
}

extension SDToggleAction {
    func storeSectionAction(isSelected: Bool) -> StoreSectionAction? {
        (isSelected ? selected : unselected).storeSectionAction
    }
}
