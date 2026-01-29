import UIKit

import Common
import DesignSystem
import SnapKit

final class StoreDetailDividerCell: BaseCollectionViewCell {
    enum Layout {
        static let defaultHeight: CGFloat = 8
    }
    
    struct Configuration: Hashable {
        init(id: UUID = UUID(), height: CGFloat = 8, color: UIColor = Colors.gray0.color) {
            self.id = id
            self.height = height
            self.color = color
        }
        
        let id: UUID
        let height: CGFloat
        let color: UIColor
    }
    
    private let dividerView = UIView()
    private var heightConstraint: Constraint?
    private var configuration = Configuration()
    
    override func setup() {
        contentView.addSubViews([dividerView])
        updateAppearance()
    }
    
    override func bindConstraints() {
        dividerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            heightConstraint = $0.height.equalTo(configuration.height).priority(.high).constraint
        }
    }
    
    func configure(with configuration: Configuration) {
        self.configuration = configuration
        updateAppearance()
        updateHeight()
    }
    
    private func updateAppearance() {
        backgroundColor = configuration.color
        dividerView.backgroundColor = configuration.color
    }
    
    private func updateHeight() {
        heightConstraint?.update(offset: configuration.height)
    }
}
