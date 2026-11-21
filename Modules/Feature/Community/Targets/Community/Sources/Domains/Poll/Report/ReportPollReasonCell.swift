import UIKit

import Common
import DesignSystem

final class ReportPollReasonCell: BaseCollectionViewCell {

    enum Layout {
        static let height: CGFloat = SelectRow.Layout.height
    }

    private let selectRow = SelectRow()

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

    func bind(title: String, isSelected: Bool) {
        selectRow.title = title
        selectRow.isSelected = isSelected
    }
}
