import UIKit

import Common
import Model
import DesignSystem

final class PhotoListViewController: BaseViewController {
    private let photoListView = PhotoListView()
    private let viewModel: PhotoListViewModel
    private var photos: [StoreDetailPhoto] = []
    
    static func instance(viewModel: PhotoListViewModel) -> PhotoListViewController {
        return PhotoListViewController(viewModel: viewModel)
    }
    
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = photoListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoListView.collectionView.delegate = self
        photoListView.collectionView.dataSource = self
        viewModel.input.viewDidLoad.send(())
    }
    
    override func bindEvent() {
        photoListView.backButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: PhotoListViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        photoListView.uploadButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapUpload)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.photos
            .main
            .withUnretained(self)
            .sink { (owner: PhotoListViewController, photos: [StoreDetailPhoto]) in
                owner.photos = photos
                owner.photoListView.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: PhotoListViewController, route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
        
        viewModel.output.showLoading
            .main
            .sink { (isShow: Bool) in
                LoadingManager.shared.showLoading(isShow: isShow)
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: PhotoListViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: PhotoListViewModel.Route) {
        switch route {
        case .presentPhotoDetail(let viewModel):
            presentPhotoDetail(viewModel: viewModel)
            
        case .presentUploadPhoto(let viewModel):
            presentUploadPhoto(viewModel: viewModel)
        }
    }
    
    private func presentUploadPhoto(viewModel: UploadPhotoViewModel) {
        let viewController = UploadPhotoViewController.instance(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
    
    private func presentPhotoDetail(viewModel: PhotoDetailViewModel) {
        let viewController = PhotoDetailViewController(viewModel: viewModel)
        
        present(viewController, animated: true)
    }
}

extension PhotoListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photo = photos[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: PhotoListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(photo)
        return cell
    }
}

extension PhotoListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.input.willDisplayCell.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapPhoto.send(indexPath.item)
    }
}
