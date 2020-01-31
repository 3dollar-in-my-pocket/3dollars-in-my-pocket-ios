import UIKit

class ImageDetailCell: BaseCollectionViewCell {
    static let registerId = "\(ImageDetailCell.self)"
    
    let imageView = UIImageView()
    
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
}
