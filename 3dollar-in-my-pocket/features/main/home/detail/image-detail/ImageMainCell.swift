import UIKit

class ImageMainCell: BaseCollectionViewCell {
    
    static let registerId = "\(ImageMainCell.self)"
    
    let mainImage = UIImageView()
    
    
    override func setup() {
        backgroundColor = .clear
        addSubview(mainImage)
    }
    
    override func bindConstraints() {
        mainImage.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func bind(image: Image) {
        mainImage.kf.setImage(with: URL(string: image.url)!)
    }
}
