import UIKit

import Common
import DesignSystem

final class ReportReviewReasonCell: BaseCollectionViewCell {

    enum Layout {
        static let horizontalInset: CGFloat = 20
        static let height: CGFloat = SelectRow.Layout.height

        static func size(containerWidth: CGFloat) -> CGSize {
            CGSize(width: containerWidth - horizontalInset * 2, height: height)
        }
    }

    private let selectRow = SelectRow()

    override var isSelected: Bool {
        didSet {
            selectRow.isSelected = isSelected
        }
    }

    override func setup() {
        super.setup()

        contentView.addSubViews([
            selectRow
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        selectRow.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bind(title: String) {
        selectRow.title = title
    }
}
