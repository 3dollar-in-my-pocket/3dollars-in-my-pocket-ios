import UIKit

import Common
import DesignSystem
import Model

import Kingfisher
import SnapKit

final class StorePreviewMetadataRowView: BaseView {
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4
        return stack
    }()

    private let primaryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let secondaryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    override func setup() {
        addSubview(containerStack)
        containerStack.addArrangedSubview(primaryStack)
        containerStack.addArrangedSubview(secondaryStack)
    }

    override func bindConstraints() {
        containerStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        primaryStack.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        secondaryStack.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }

    func configure(_ metadata: StorePreviewMetadata) {
        configureRow(stack: primaryStack, chips: metadata.primary, separator: metadata.separator)
        configureRow(stack: secondaryStack, chips: metadata.secondary, separator: metadata.separator)
        primaryStack.isHidden = metadata.primary.isEmpty
        secondaryStack.isHidden = metadata.secondary.isEmpty
    }

    private func configureRow(stack: UIStackView, chips: [SDChip], separator: SDImage) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, chip) in chips.enumerated() {
            stack.addArrangedSubview(makeChipView(chip))
            if index != chips.count - 1 {
                stack.addArrangedSubview(makeSeparator(separator))
            }
        }
    }

    private func makeChipView(_ chip: SDChip) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 2

        if let image = chip.image {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.setSDImage(image)
            container.addArrangedSubview(imageView)
        }

        if let text = chip.text {
            let label = UILabel()
            label.setSDText(text)
            container.addArrangedSubview(label)
        }

        return container
    }

    private func makeSeparator(_ image: SDImage) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setSDImage(image)
        return imageView
    }
}
