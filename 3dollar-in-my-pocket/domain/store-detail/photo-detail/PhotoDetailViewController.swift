import UIKit

import Base
import ReactorKit
import RxSwift

final class PhotoDetailViewController: BaseViewController, View, PhotoDetailCoordinator {
    private let photoDetailView = PhotoDetailView()
    private let photoDeetailReactor: PhotoDetailReactor
    private weak var coordinator: PhotoDetailCoordinator?
    
    init(storeId: Int, index: Int, photos: [Image]) {
        self.photoDeetailReactor = PhotoDetailReactor(
            storeId: storeId,
            selectedIndex: index,
            photos: photos,
            storeService: StoreService(),
            globalState: GlobalState.shared
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instance(
        storeId: Int,
        index: Int,
        photos: [Image]
    ) -> PhotoDetailViewController {
        return PhotoDetailViewController(
            storeId: storeId,
            index: index,
            photos: photos
        ).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.photoDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = self.photoDeetailReactor
        self.coordinator = self
    }
    
    override func bindEvent() {
        self.photoDetailView.closeButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.photoDetailView.deleteButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showDeleteAlert()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.photoDeetailReactor.dismissPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.eventDisposeBag)
        
        self.photoDeetailReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.photoDeetailReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: PhotoDetailReactor) {
        // Bind Action
        self.photoDetailView.mainPhotoCollectionView.rx.didScroll
            .map { [weak self] _ -> IndexPath in
                guard let self = self else { return IndexPath(row: 0, section: 0) }
                let xContentOffste = self.photoDetailView.mainPhotoCollectionView.contentOffset.x
                let screenWidth = self.view.frame.width
                let proportionalOffset = xContentOffste / screenWidth
                
                return IndexPath(row: Int(proportionalOffset), section: 0)
            }
            .map { Reactor.Action.scrollMainPhoto(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.photoDetailView.subPhotoCollectionView.rx.itemSelected
            .map { Reactor.Action.tapSubPhoto(index: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { $0.photos }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.photoDetailView.mainPhotoCollectionView.rx.items(
                cellIdentifier: PhotoMainCollectionViewCell.registerId,
                cellType: PhotoMainCollectionViewCell.self
            )) { row, image, cell in
                cell.bind(photo: image)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.photos }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.photoDetailView.subPhotoCollectionView.rx.items(
                cellIdentifier: PhotoSubCollectionViewCell.registerId,
                cellType: PhotoSubCollectionViewCell.self
            )) { row, image, cell in
                cell.bind(photo: image)
            }
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.selectedIndex }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(self.photoDetailView.rx.selectedIndex)
            .disposed(by: self.disposeBag)
    }
}
