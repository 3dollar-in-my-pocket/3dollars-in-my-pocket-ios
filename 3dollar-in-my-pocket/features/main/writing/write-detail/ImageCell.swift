import UIKit

class ImageCell: BaseCollectionViewCell {
    
    static let registerId = "\(ImageCell.self)"
    
    let imageView = UIImageView().then {
        $0.backgroundColor = UIColor.init(r: 240, g: 240, b: 240)
        $0.layer.cornerRadius = 6
        $0.layer.borderColor = UIColor.init(r: 200, g: 200, b: 200).cgColor
        $0.layer.borderWidth = 0.8
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    let cameraIcon = UIImageView().then {
        $0.image = UIImage.init(named: "ic_camera")
        $0.contentMode = .scaleAspectFit
    }
    
    
    override func setup() {
        backgroundColor = .clear
        addSubViews(imageView, cameraIcon)
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.height.equalTo(104)
        }
        
        cameraIcon.snp.makeConstraints { (make) in
            make.center.equalTo(imageView.snp.center)
            make.width.height.equalTo(48)
        }
    }
    
    func setImage(image: UIImage?) {
        if let image = image {
            imageView.layer.borderWidth = 0
            cameraIcon.isHidden = true
            imageView.image = image
        } else {
            imageView.layer.borderWidth = 0.8
            cameraIcon.isHidden = false
            imageView.image = nil
        }
        
    }
}
