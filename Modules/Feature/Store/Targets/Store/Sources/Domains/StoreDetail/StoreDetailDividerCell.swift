import UIKit

import Common
import DesignSystem

final class StoreDetailDividerCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 8
    }
    
    private let dividerView = UIView().then {
        $0.backgroundColor = Colors.gray10.color
    }
    
    override func setup() {
        backgroundColor = Colors.gray10.color
        
        contentView.addSubViews([dividerView])
    }
    
    override func bindConstraints() {
        dividerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(Layout.height).priority(.high)
        }
    }
}
