import UIKit

import Common
import DesignSystem
import Model

final class HomeStoreCardInfoView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        spacing = 4
        axis = .horizontal
        snp.makeConstraints {
            $0.height.equalTo(12)
        }
    }
    
    func bind(_ metadatas: [SDChip]) {
        for metadata in metadatas {
            let metadataLabel = MetadataLabel(sdChip: metadata)
            
            addArrangedSubview(metadataLabel)
            
            if metadatas.last != metadata {
                let divider = UIView()
                divider.backgroundColor = Colors.gray70.color
                divider.snp.makeConstraints {
                    $0.width.equalTo(1)
                    $0.height.equalTo(8)
                }
                addArrangedSubview(divider)
            }
        }
    }
    
    func prepareForReuse() {
        arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}

extension HomeStoreCardInfoView {
    private class MetadataLabel: UIStackView {
        private let metadata: SDChip
        
        init(sdChip: SDChip) {
            self.metadata = sdChip
            super.init(frame: .zero)
            
            setupUI()
        }
        
        @MainActor required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            axis = .horizontal
            spacing = 2
            
            if let image = metadata.image {
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
            label.textColor = Colors.gray40.color
            label.setSDText(metadata.text)
            addArrangedSubview(label)
        }
        
    }
}
