import UIKit
import Kingfisher

class ImageDetailVC: BaseVC {
    private lazy var imageDetailView = ImageDetailView(frame: self.view.frame)
    
    private var images: [Image]!
    private var storeName: String!
    
    static func instance(title: String, images: [Image]) -> ImageDetailVC {
        return ImageDetailVC.init(nibName: nil, bundle: nil).then {
            $0.images = images
            $0.storeName = title
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = imageDetailView
        setupCollectionView()
        imageDetailView.titleLabel.text = storeName
        imageDetailView.mainImage.kf.setImage(with: URL(string: images[0].url)!)
    }
    
    override func bindViewModel() {
        imageDetailView.closeBtn.rx.tap.bind { [weak self] in
            self?.dismiss(animated: false, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        imageDetailView.collectionView.delegate = self
        imageDetailView.collectionView.dataSource = self
        imageDetailView.collectionView.register(ImageDetailCell.self, forCellWithReuseIdentifier: ImageDetailCell.registerId)
    }
}

extension ImageDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailCell.registerId, for: indexPath) as? ImageDetailCell else {
            return BaseCollectionViewCell()
        }
        
        cell.bind(image: images[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 64, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        self.imageDetailView.mainImage.kf.setImage(with: URL(string: self.images[indexPath.row].url))
    }
}
