import UIKit

import RxSwift
import ReactorKit

final class PhotoListViewController: BaseViewController, View, PhotoListCoordinator {
    private let photoListView = PhotoListView()
    private let photoListReactor: PhotoListReactor
    private weak var coordinator: PhotoListCoordinator?
    
    init(storeId: Int) {
        self.photoListReactor = PhotoListReactor(
            storeId: storeId,
            storeService: StoreService(),
            globalState: GlobalState.shared
        )
        
        super.init(nibName: nil, bundle: nil)
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    static func instance(storeid: Int) -> PhotoListViewController {
        return PhotoListViewController(storeId: storeid)
    }
    
    override func loadView() {
        self.view = self.photoListView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.photoListReactor
        self.coordinator = self
        self.photoListReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.photoListView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.presenter.navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.photoListReactor.presentPhotoDetailPublisher
            .asDriver(onErrorJustReturn: (0, 0, []))
            .drive(onNext: { [weak self] storeId, index, photos in
                self?.coordinator?.presentPhotoDetail(
                    storeId: storeId,
                    selectedIndex: index,
                    photos: photos
                )
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: PhotoListReactor) {
        // Bind Action
        self.photoListView.photoCollectionView.rx.itemSelected
            .map { Reactor.Action.tapPhoto(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.photos }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.photoListView.photoCollectionView.rx.items(
                cellIdentifier: PhotoListCollectionViewCell.registerId,
                cellType: PhotoListCollectionViewCell.self
            )) { _, photo, cell in
                cell.bind(photo: photo)
            }
            .disposed(by: self.disposeBag)
    }
}
