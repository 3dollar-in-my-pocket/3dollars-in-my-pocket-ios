import UIKit

import DesignSystem

final class StoreDetailBaseInfoAppearanceDayStackItemView: UILabel {
    enum Layout {
        static let size = CGSize(width: 24, height: 24)
    }
    
    override var intrinsicContentSize: CGSize {
        return Layout.size
    }
    
    init(value: String) {
        super.init(frame: .zero)
        
        setup(value: value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ isSelected: Bool) {
        backgroundColor = isSelected ? Colors.gray70.color : Colors.gray10.color
        textColor = isSelected ? Colors.systemWhite.color : Colors.gray40.color
    }
    
    private func setup(value: String) {
        text = value
        backgroundColor = Colors.gray10.color
        textColor = Colors.gray40.color
        font = Fonts.medium.font(size: 12)
        textAlignment = .center
        layer.cornerRadius = 12
        layer.masksToBounds = true
    }
}
