import UIKit

import ReactorKit
import RxDataSources

final class MyMedalViewController: BaseViewController, View, MyMedalCoordinator {
    private let myMedalView = MyMedalView()
    private let myMedalReactor: MyMedalReator
    private weak var coordinator: MyMedalCoordinator?
    private var medalCollectionViewdataSource
    : RxCollectionViewSectionedReloadDataSource<MyMedalSectionModel>!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(medal: Medal) -> MyMedalViewController {
        return MyMedalViewController(medal: medal).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(medal: Medal) {
        self.myMedalReactor = MyMedalReator(
            medal: medal,
            metaContext: MetaContext.shared,
            medalService: MedalService(),
            globalState: GlobalState.shared
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.myMedalView
    }
    
    override func viewDidLoad() {
        self.setupDataSource()
        super.viewDidLoad()
        
        self.coordinator = self
        self.reactor = self.myMedalReactor
        self.myMedalReactor.action.onNext(.viewDidLoad)
    }
    
    override func bindEvent() {
        self.myMedalView.backButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                self?.coordinator?
                    .presenter
                    .navigationController?
                    .popViewController(animated: true)
            })
            .disposed(by: self.eventDisposeBag)
        
        self.myMedalReactor.showErrorAlertPublisher
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.eventDisposeBag)
    }
    
    func bind(reactor: MyMedalReator) {
        // Bind Action
        self.myMedalView.collectionView.rx.itemSelected
            .filter { $0.section == 1 }
            .map { Reactor.Action.tapMedal(row: $0.row) }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        // Bind State
        reactor.state
            .map { [
                MyMedalSectionModel(currentMedal: $0.currentMedal),
                MyMedalSectionModel(medals: $0.medals)
            ]}
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: [])
            .drive(self.myMedalView.collectionView.rx.items(
                dataSource: self.medalCollectionViewdataSource
            ))
            .disposed(by: self.disposeBag)
        
        reactor.pulse(\.$presentMedalInfo)
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showMedalInfo()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.medalCollectionViewdataSource
        = RxCollectionViewSectionedReloadDataSource<MyMedalSectionModel>
        { _, collectionView, indexPath, item in
            switch item {
            case .currentMedal(let medal):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MyMedalCollectionCell.registerId,
                    for: indexPath
                ) as? MyMedalCollectionCell else {
                    return BaseCollectionViewCell()
                }
                cell.bind(medal: medal)
                
                return cell
                
            case .medal(let medal):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MedalCollectionCell.registerId,
                    for: indexPath
                ) as? MedalCollectionCell else {
                    return BaseCollectionViewCell()
                }
                cell.bind(medal: medal)
                
                return cell
            }
        }
        
        self.medalCollectionViewdataSource.configureSupplementaryView =
        { dataSource, collectionView, kind, indexPath in
            guard let cell = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MedalHeaderView.registerId,
                    for: indexPath
            ) as? MedalHeaderView else {
                return UICollectionReusableView()
            }
            
            cell.infoButton.rx.tap
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .asDriver(onErrorJustReturn: ())
                .drive(onNext: { [weak self] in
                    self?.coordinator?.showMedalInfo()
                })
                .disposed(by: cell.disposeBag)
            
            return cell
        }
    }
}
