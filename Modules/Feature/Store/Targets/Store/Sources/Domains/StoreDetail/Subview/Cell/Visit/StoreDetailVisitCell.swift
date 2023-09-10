import UIKit

import Common
import DesignSystem

final class StoreDetailVisitCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 248
    }
    
    private let successSummryView = StoreDetailVisitSummryView()
    
    private let failSummryView = StoreDetailVisitSummryView()
    
    private let historyView = StoreDetailVisitHistoryView()
    
    override func setup() {
        contentView.addSubViews([
            successSummryView,
            failSummryView,
            historyView
        ])
    }
    
    override func bindConstraints() {
        successSummryView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(snp.centerX).offset(-4)
            $0.top.equalToSuperview()
        }
        
        failSummryView.snp.makeConstraints {
            $0.left.equalTo(snp.centerX).offset(4)
            $0.right.equalToSuperview()
            $0.centerY.equalTo(successSummryView)
        }
        
        historyView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(successSummryView.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
}
