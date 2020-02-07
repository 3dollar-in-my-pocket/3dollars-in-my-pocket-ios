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
        imageDetailView.collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: .left)
        
        imageDetailView.mainImageCollectionView.delegate = self
        imageDetailView.mainImageCollectionView.dataSource = self
        imageDetailView.mainImageCollectionView.register(ImageMainCell.self, forCellWithReuseIdentifier: ImageMainCell.registerId)
    }
}

extension ImageDetailVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageMainCell.registerId, for: indexPath) as? ImageMainCell else {
                return BaseCollectionViewCell()
            }
            
            cell.bind(image: images[indexPath.row])
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailCell.registerId, for: indexPath) as? ImageDetailCell else {
                return BaseCollectionViewCell()
            }
            
            cell.bind(image: images[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            return CGSize.init(width: self.view.frame.width, height: self.view.frame.width)
        } else {
            return CGSize.init(width: 64, height: 64)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            self.imageDetailView.mainImageCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 0 {
            let proportionalOffset = scrollView.contentOffset.x / self.view.frame.width
            let indexPath = IndexPath(row: Int(proportionalOffset), section: 0)

            self.imageDetailView.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        }
    }
}
