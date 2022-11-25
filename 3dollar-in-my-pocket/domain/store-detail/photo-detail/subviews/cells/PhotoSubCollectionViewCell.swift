import UIKit

final class PhotoSubCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(PhotoSubCollectionViewCell.self)"
    static let itemSize = CGSize(width: 40, height: 40)
    
    override var isSelected: Bool {
        didSet {
            self.photo.alpha = isSelected ? 1 : 0.6
            if isSelected {
                self.photo.layer.borderWidth = 2
                self.photo.layer.borderColor = UIColor(r: 255, g: 92, b: 67).cgColor
            } else {
                self.photo.layer.borderWidth = 0
            }
        }
    }
    
    private let photo = UIImageView().then {
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.alpha = 0.6
        $0.contentMode = .scaleAspectFill
    }
    
    
    override func setup() {
        self.addSubViews(self.photo)
    }
    
    override func bindConstraints() {
        self.photo.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    func bind(photo: Image) {
        self.photo.setImage(urlString: photo.url)
    }
}
