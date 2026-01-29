import UIKit

import Common
import DesignSystem
import SnapKit

final class StoreDetailDividerCell: BaseCollectionViewCell {
    enum Layout {
        static let defaultHeight: CGFloat = 8
    }
    
    // Configuration struct for dynamic properties
    struct Configuration: Hashable {
        init(height: CGFloat, color: UIColor) {
            self.height = height
            self.color = color
        }
        
        let id: UUID = UUID()
        let height: CGFloat
        let color: UIColor
        
        static let `default` = Configuration(
            height: Layout.defaultHeight,
            color: Colors.gray0.color
        )
    }
    
    private let dividerView = UIView()
    private var heightConstraint: Constraint?
    private var configuration = Configuration.default
    
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
    
    func configure(height: CGFloat = Layout.defaultHeight, color: UIColor = Colors.gray0.color) {
        let config = Configuration(height: height, color: color)
        configure(with: config)
    }
    
    private func updateAppearance() {
        backgroundColor = configuration.color
        dividerView.backgroundColor = configuration.color
    }
    
    private func updateHeight() {
        heightConstraint?.update(offset: configuration.height)
    }
}
