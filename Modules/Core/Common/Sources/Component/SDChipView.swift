import UIKit

import Model

import Kingfisher
import SnapKit

public final class SDChipView: BaseView {
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public let titleLabel = UILabel()

    public let additionalLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private var imageWidthConstraint: Constraint?
    private var imageHeightConstraint: Constraint?
    private let defaultSpacing: CGFloat

    public init(spacing: CGFloat = 0) {
        self.defaultSpacing = spacing
        super.init(frame: .zero)

        stackView.spacing = spacing
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    public func bind(_ chip: SDChip) {
        // 서버가 칩별 아이콘-텍스트 간격을 지정하면 우선 적용한다.
        stackView.spacing = chip.contentSpacing.map { CGFloat($0) } ?? defaultSpacing
        setImage(chip.image)
        titleLabel.setSDText(chip.text)
        additionalLabel.isHidden = chip.additionalText == nil
        additionalLabel.setSDText(chip.additionalText)

        if let style = chip.style {
            setSDChipStyle(style)
        }
    }

    public func prepareForReuse() {
        imageView.clear()
        imageView.snp.removeConstraints()
        imageView.isHidden = false
        titleLabel.text = nil
        titleLabel.attributedText = nil
        additionalLabel.text = nil
        additionalLabel.attributedText = nil
        additionalLabel.isHidden = true
    }

    private func setupUI() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(additionalLabel)
        addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setImage(_ image: SDImage?) {
        guard let image else {
            imageView.isHidden = true
            return
        }
        imageView.isHidden = false
        imageView.setSDImage(image)
    }
}
