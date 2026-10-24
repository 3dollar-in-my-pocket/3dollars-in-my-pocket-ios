import UIKit

import DesignSystem
import Model

import SnapKit

public final class SDLabelChipStackView: UIStackView {
    public enum Layout {
        public static let height: CGFloat = 18
        static let horizontalInset: CGFloat = 6
        static let lineHeight: CGFloat = 14
        static let spacing: CGFloat = 4
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        alignment = .center
        spacing = Layout.spacing
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func bind(_ chips: [SDChip]) {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
        chips.forEach { addArrangedSubview(makeChipView($0)) }
        isHidden = chips.isEmpty
    }

    private func makeChipView(_ chip: SDChip) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = Layout.height / 2
        containerView.layer.masksToBounds = true
        if let style = chip.style {
            containerView.setSDChipStyle(style)
        }

        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 10)
        label.setSDText(chip.text, lineHeight: Layout.lineHeight)
        containerView.addSubview(label)

        label.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalToSuperview()
        }
        containerView.snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
        containerView.setContentHuggingPriority(.required, for: .horizontal)
        containerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return containerView
    }
}
