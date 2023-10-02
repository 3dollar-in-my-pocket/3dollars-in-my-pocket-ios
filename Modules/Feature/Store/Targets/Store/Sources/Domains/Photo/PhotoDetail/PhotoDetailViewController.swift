import UIKit

import Common
import Model
import DesignSystem

final class PhotoDetailViewController: BaseViewController {
    private let photoDetailView = PhotoDetailView()
    private let viewModel: PhotoDetailViewModel
    private var photos: [StoreDetailPhoto] = []
    private var isFirstLoad = true
    
    static func instance(viewModel: PhotoDetailViewModel) -> PhotoDetailViewController {
        return PhotoDetailViewController(viewModel: viewModel)
    }
    
    init(viewModel: PhotoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = photoDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoDetailView.collectionView.dataSource = self
        photoDetailView.collectionView.delegate = self
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        photoDetailView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        photoDetailView.leftButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapLeft)
            .store(in: &cancellables)
        
        photoDetailView.rightButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapRight)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.photos
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, photos: [StoreDetailPhoto]) in
                owner.photos = photos
                owner.photoDetailView.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToIndex
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, indexWithAnimated) in
                let (index, animated) = indexWithAnimated
                owner.photoDetailView.collectionView.scrollToItem(
                    at: IndexPath(row: index, section: 0),
                    at: .centeredHorizontally,
                    animated: animated
                )
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { isShow in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: PhotoDetailViewController, error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
}

extension PhotoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photo = photos[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: PhotoDetailCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(photo)
        
        return cell
    }
}

extension PhotoDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
        
        if isFirstLoad {
            isFirstLoad = false
            viewModel.input.onCollectionViewLoad.send(())
        }
    }
}
