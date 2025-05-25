import UIKit

import Common
import DesignSystem
import Model

final class HomeStoreCardCellTagView: UIStackView {
    enum Layout {
        static let defaultImageSize = CGSize(width: 16, height: 16)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = Colors.gray80.color
        layer.cornerRadius = 12
        layer.masksToBounds = true
        layoutMargins = .init(top: 4, left: 8, bottom: 4, right: 8)
        isLayoutMarginsRelativeArrangement = true
        spacing = 4
    }
    
    func bind(chip: SDChip) {
        if let image = chip.image {
            let imageView = UIImageView()
            imageView.setImage(urlString: image.url)
            
            imageView.snp.makeConstraints {
                $0.width.equalTo(image.style.width)
                $0.height.equalTo(image.style.height)
            }
            addArrangedSubview(imageView)
        }
        
        let label = UILabel()
        label.font = Fonts.medium.font(size: 12)
        label.setSDText(chip.text)
        addArrangedSubview(label)
        
        if let style = chip.style {
            backgroundColor = UIColor(hex: style.backgroundColor)
        }
    }
}
