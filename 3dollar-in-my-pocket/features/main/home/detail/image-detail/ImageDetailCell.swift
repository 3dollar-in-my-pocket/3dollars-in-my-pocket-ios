import UIKit

class ImageDetailCell: BaseCollectionViewCell {
    static let registerId = "\(ImageDetailCell.self)"
    
    let imageView = UIImageView().then {
        $0.alpha = 0.6
    }
    
    override func setup() {
        layer.cornerRadius = 6
        layer.masksToBounds = true
        addSubViews(imageView)
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func bind(image: Image) {
        imageView.kf.setImage(with: URL(string: image.url))
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.alpha = 1
            }
            else {
                imageView.alpha = 0.6
            }
        }
    }
}
