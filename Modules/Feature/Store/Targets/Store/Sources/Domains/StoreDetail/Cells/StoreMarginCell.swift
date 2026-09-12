import UIKit

import Common
import DesignSystem
import Model
import SnapKit

/// 서버가 지정한 높이만큼 섹션 사이를 채우는 구분 띠.
final class StoreMarginCell: BaseCollectionViewCell {
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        return view
    }()

    private var heightConstraint: Constraint?

    override func setup() {
        contentView.addSubview(dividerView)
    }

    override func bindConstraints() {
        dividerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            heightConstraint = $0.height.equalTo(8).constraint
        }
    }

    func bind(_ section: StoreMarginSection) {
        heightConstraint?.update(offset: section.height)
    }
}
