import UIKit

import Common
import DesignSystem
import Model

final class ReportReasonCell: BaseCollectionViewCell {
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectRow.title = nil
    }
    
    override func setup() {
        contentView.addSubViews([
            selectRow
        ])
    }
    
    override func bindConstraints() {
        selectRow.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ reason: ReportReason) {
        selectRow.title = reason.description
    }
}
