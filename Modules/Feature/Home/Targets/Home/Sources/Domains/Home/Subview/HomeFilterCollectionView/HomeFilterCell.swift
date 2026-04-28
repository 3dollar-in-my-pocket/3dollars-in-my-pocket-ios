import UIKit

import Common
import DesignSystem
import Model

import Kingfisher
import SnapKit

final class HomeFilterCell: BaseCollectionViewCell {
    enum Layout {
        static let leadingMargin: CGFloat = 10
        static let stackViewSpacing: CGFloat = 6
        static let trailingMargin: CGFloat = 10
        static let height: CGFloat = 34
        static let labelHeight: CGFloat = 18
        static let defaultIconSize: CGFloat = 20
        static let closeButtonSize: CGFloat = 14

        static func size(for chip: SDChip) -> CGSize {
            sizingCell.bind(chip: chip, surface: nil)
            return measureSizingCell()
        }

        static func size(for button: SDButton) -> CGSize {
            sizingCell.bind(button: button, surface: nil)
            return measureSizingCell()
        }

        static func sizeForSelectedCategory(chip: SDChip) -> CGSize {
            sizingCell.bindSelectedCategory(chip: chip, onClose: {})
            return measureSizingCell()
        }

        private static let sizingCell = HomeFilterCell()

        private static func measureSizingCell() -> CGSize {
            sizingCell.setNeedsLayout()
            sizingCell.layoutIfNeeded()
            let fittingSize = sizingCell.contentView.systemLayoutSizeFitting(
                CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
                withHorizontalFittingPriority: .fittingSizeLevel,
                verticalFittingPriority: .required
            )
            return CGSize(width: ceil(fittingSize.width), height: height)
        }
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = Layout.stackViewSpacing
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Icons.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        button.isHidden = true
        return button
    }()

    private var iconWidthConstraint: Constraint?
    private var iconHeightConstraint: Constraint?
    private var onClose: (() -> Void)?

    override func prepareForReuse() {
        super.prepareForReuse()

        iconImageView.kf.cancelDownloadTask()
        iconImageView.image = nil
        iconImageView.isHidden = false
        titleLabel.text = nil
        titleLabel.attributedText = nil
        layer.borderColor = nil
        layer.borderWidth = 0
        layer.cornerRadius = 10
        backgroundColor = nil
        closeButton.isHidden = true
        onClose = nil
    }

    override func setup() {
        layer.cornerRadius = 10
        layer.masksToBounds = true

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(closeButton)

        iconImageView.snp.makeConstraints {
            iconWidthConstraint = $0.width.equalTo(Layout.defaultIconSize).constraint
            iconHeightConstraint = $0.height.equalTo(Layout.defaultIconSize).constraint
        }

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(Layout.labelHeight)
        }

        closeButton.snp.makeConstraints {
            $0.size.equalTo(Layout.closeButtonSize)
        }

        closeButton.addAction(UIAction { [weak self] _ in
            self?.onClose?()
        }, for: .touchUpInside)

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.leadingMargin)
            $0.trailing.equalToSuperview().offset(-Layout.trailingMargin)
            $0.centerY.equalToSuperview()
        }
    }

    func bind(chip: SDChip, surface: SDSurfaceStyle?) {
        closeButton.isHidden = true
        applyImage(chip.image)
        titleLabel.setSDText(chip.text)
        applyBackground(surface: surface, fallbackHex: chip.style?.backgroundColor)
    }

    func bind(button: SDButton, surface: SDSurfaceStyle?) {
        closeButton.isHidden = true
        applyImage(button.image)
        titleLabel.setSDText(button.text)
        applyBackground(surface: surface, fallbackHex: button.style.backgroundColor)
    }

    func bindSelectedCategory(chip: SDChip, onClose: @escaping () -> Void) {
        applyImage(chip.image)
        titleLabel.setSDText(chip.text)
        titleLabel.textColor = Colors.pink500.color

        backgroundColor = Colors.pink100.color
        layer.borderColor = Colors.pink500.color.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 10

        closeButton.isHidden = false
        closeButton.tintColor = Colors.pink500.color
        self.onClose = onClose
    }

    private func applyImage(_ image: SDImage?) {
        guard let image, let url = URL(string: image.url) else {
            iconImageView.isHidden = true
            iconWidthConstraint?.update(offset: 0)
            iconHeightConstraint?.update(offset: 0)
            return
        }
        iconImageView.isHidden = false
        iconWidthConstraint?.update(offset: image.style.width)
        iconHeightConstraint?.update(offset: image.style.height)
        iconImageView.kf.setImage(with: url)
    }

    private func applyBackground(surface: SDSurfaceStyle?, fallbackHex: String?) {
        if let surface {
            setSDSurfaceStyle(surface)
        } else if let fallbackHex, let color = UIColor(hex: fallbackHex) {
            backgroundColor = color
        } else {
            backgroundColor = Colors.systemWhite.color
            layer.borderColor = Colors.gray30.color.cgColor
            layer.borderWidth = 1
        }
    }
}
