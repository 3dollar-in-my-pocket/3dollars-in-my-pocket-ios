import UIKit

import Base
import RxDataSources

protocol MyMedalViewControllerDelegate: AnyObject {
    func onChangeMedal(medal: Medal)
}

final class MyMedalViewController: BaseVC, MyMedalCoordinator {
    weak var delegate: MyMedalViewControllerDelegate?
    private let myMedalView = MyMedalView()
    private let viewModel: MyMedalViewModel
    private weak var coordinator: MyMedalCoordinator?
    private var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, Medal>>!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance(medal: Medal) -> MyMedalViewController {
        return MyMedalViewController(medal: medal).then {
            $0.hidesBottomBarWhenPushed = true
        }
    }
    
    init(medal: Medal) {
        self.viewModel = MyMedalViewModel(
            medal: medal,
            metaContext: MetaContext.shared,
            medalService: MedalService()
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
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func bindEvent() {
        self.myMedalView.backButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.popup()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelInput() {
        self.myMedalView.collectionView.rx.itemSelected
            .filter { $0.section == 1 }
            .map { $0.row }
            .bind(to: self.viewModel.input.tapMedal)
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.medalsPublisher
            .asDriver(onErrorJustReturn: [])
            .drive(self.myMedalView.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.selectMedalPublisher
            .asDriver(onErrorJustReturn: 0)
            .drive(self.myMedalView.rx.selectMedal)
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.updateMyPageMedalPublisher
            .asDriver(onErrorJustReturn: Medal())
            .drive(onNext: { [weak self] medal in
                self?.delegate?.onChangeMedal(medal: medal)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.output.showMedalInfoPublisher
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showMedalInfo()
            })
            .disposed(by: self.disposeBag)
            
        self.viewModel.showErrorAlert
            .asDriver(onErrorJustReturn: BaseError.unknown)
            .drive(onNext: { [weak self] error in
                self?.coordinator?.showErrorAlert(error: error)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setupDataSource() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Medal>> { _, collectionView, indexPath, item in
            if indexPath.section == 0 {
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MyMedalCollectionCell.registerId,
                        for: indexPath
                ) as? MyMedalCollectionCell else {
                    return BaseCollectionViewCell()
                }
                cell.bind(medal: item)
                
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MedalCollectionCell.registerId,
                        for: indexPath
                ) as? MedalCollectionCell else {
                    return BaseCollectionViewCell()
                }
                cell.bind(medal: item)
                
                return cell
            }
        }
        
        self.dataSource.configureSupplementaryView = { dataSource, collectionView, kind, indexPath in
            guard let cell = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MedalHeaderView.registerId,
                    for: indexPath
            ) as? MedalHeaderView else {
                return UICollectionReusableView()
            }
            
            cell.bind(title: dataSource.sectionModels[indexPath.section].model)
            cell.infoButton.rx.tap
                .asDriver()
                .drive(onNext: { [weak self] in
                    self?.coordinator?.showMedalInfo()
                })
                .disposed(by: cell.disposeBag)
                
            return cell
        }
    }
}
