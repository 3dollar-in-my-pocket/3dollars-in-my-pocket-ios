import UIKit
import Photos

import Common
import DesignSystem

final class UploadPhotoCell: BaseCollectionViewCell {
    enum Layout {
        static let space: CGFloat = 8
        static let width: CGFloat = (UIUtils.windowBounds.width - 64)/3
        static let itemSize = CGSize(width: width, height: width)
    }
    
    var imageRequestId: PHImageRequestID?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = Colors.mainPink.color.cgColor
        imageView.layer.borderWidth = 0
        
        return imageView
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 0.3)
        view.layer.cornerRadius = 2
        view.isHidden = true
        
        return view
    }()
    
    private let circleView: UIView = {
        let circleView = UIView()
        circleView.layer.cornerRadius = 10
        circleView.layer.borderWidth = 1
        circleView.layer.borderColor = Colors.gray20.color.cgColor
        
        return circleView
    }()
    
    private let checkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.check.image.withTintColor(Colors.mainPink.color)
        imageView.isHidden = true
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let imageRequestId = self.imageRequestId {
            PHImageManager.default().cancelImageRequest(imageRequestId)
        }
        isSelected = false
    }
    
    override func setup() {
        contentView.addSubViews([
            imageView,
            dimView,
            circleView,
            checkImage
        ])
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalTo(imageView)
        }
        
        circleView.snp.makeConstraints {
            $0.top.equalTo(imageView).offset(8)
            $0.right.equalTo(imageView).offset(-8)
            $0.size.equalTo(20)
        }
        
        checkImage.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.center.equalTo(circleView)
        }
    }
    
    func bind(asset: PHAsset) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        imageRequestId = PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFit,
            options: options
        ) { [weak self] (image, _) in
            self?.imageView.image = image
        }
    }
    
    private func setSelected(_ isSelected: Bool) {
        imageView.layer.borderWidth = isSelected ? 1 : 0
        dimView.isHidden = isSelected ? false : true
        circleView.layer.borderWidth = isSelected ? 0 : 1
        circleView.backgroundColor = isSelected ? Colors.gray100.color : .clear
        checkImage.isHidden = isSelected ? false : true
    }
}
