import UIKit

import Common
import DesignSystem
import Model

import SnapKit

final class StorePreviewBodyCardView: BaseView {
    private let label: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.textColor = Colors.gray70.color
        label.numberOfLines = 2
        return label
    }()

    override func setup() {
        backgroundColor = Colors.gray10.color
        layer.cornerRadius = 12
        clipsToBounds = true
        addSubview(label)
    }

    override func bindConstraints() {
        label.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
    }

    func configure(body: StorePreviewBody) {
        label.setSDText(body.text)
        setSDSurfaceStyle(body.style)
    }
}
