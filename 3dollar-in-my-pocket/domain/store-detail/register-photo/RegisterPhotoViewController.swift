import Foundation
import UIKit

import Base
import RxSwift
import ReactorKit

protocol RegisterPhotoDelegate: AnyObject {
    func onSaveSuccess()
}

final class RegisterPhotoViewController: BaseViewController, View, RegisterPhotoCoordinator {
    weak var delegate: RegisterPhotoDelegate?
    private let registerPhotoView = RegisterPhotoView()
    private let registerPhotoReactor: RegisterPhotoReactor
    private weak var coordinator: RegisterPhotoCoordinator?
    
    static func instance(storeId: Int) -> RegisterPhotoViewController {
        return RegisterPhotoViewController(storeId: storeId).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    init(storeId: Int) {
        self.registerPhotoReactor = RegisterPhotoReactor(
            storeId: storeId,
            storeService: StoreService(),
            photoManager: PhotoManager.shared,
            globalState: GlobalState.shared
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.registerPhotoView
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.registerPhotoReactor
        self.registerPhotoReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.registerPhotoView.closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.dismiss(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.registerPhotoReactor.dismissPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?.presenter.dismiss(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.registerPhotoReactor.showLoadingPublisher
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isShow in
                self?.coordinator?.showLoading(isShow: isShow)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.registerPhotoReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.registerPhotoReactor.deSelectPublisher
            .asDriver(onErrorJustReturn: 0)
            .drive { [weak self] row in
                self?.registerPhotoView.deselectCollectionItem(index: row)
            }
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: RegisterPhotoReactor) {
        // Bind Action
        self.registerPhotoView.photoCollectionView.rx.itemSelected
            .map { Reactor.Action.selectAsset(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.registerPhotoView.photoCollectionView.rx.itemDeselected
            .map { Reactor.Action.deSelectAsset(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.registerPhotoView.registerButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.tapRegister }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { !$0.selectedAssets.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(self.registerPhotoView.registerButton.rx.inEnable)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.selectedAssets.count }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            .drive(self.registerPhotoView.registerButton.rx.photoCount)
            .disposed(by: self.disposeBag)
        
        reactor.state
            .map { $0.assets }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.registerPhotoView.photoCollectionView.rx.items(
                cellIdentifier: RegisterPhotoCollectionViewCell.registerId,
                cellType: RegisterPhotoCollectionViewCell.self
            )) { _, asset, cell in
                cell.bind(asset: asset)
            }
            .disposed(by: self.disposeBag)
    }
    
//    override func bindViewModelOutput() {
//        self.viewModel.output.deSelectPublisher
//            .asDriver(onErrorJustReturn: -1)
//            .drive(onNext: { [weak self] index in
//                self?.registerPhotoView.deselectCollectionItem(index: index)
//            })
//            .disposed(by: self.disposeBag)
//    }
}
