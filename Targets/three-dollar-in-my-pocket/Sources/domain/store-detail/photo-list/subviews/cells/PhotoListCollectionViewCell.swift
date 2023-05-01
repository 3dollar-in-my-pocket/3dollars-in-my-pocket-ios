import UIKit

final class PhotoListCollectionViewCell: BaseCollectionViewCell {
    static let registerId = "\(PhotoListCollectionViewCell.self)"
    static let itemSize = CGSize(
        width: (Int(UIScreen.main.bounds.width) - 64)/3,
        height: (Int(UIScreen.main.bounds.width) - 64)/3
    )
    
    private let photo = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 2
        $0.layer.masksToBounds = true
    }
    
    override func setup() {
        self.backgroundColor = .clear
        self.addSubViews(photo)
    }
    
    override func bindConstraints() {
        self.photo.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    func bind(photo: Image) {
        self.photo.setImage(urlString: photo.url)
    }
}
