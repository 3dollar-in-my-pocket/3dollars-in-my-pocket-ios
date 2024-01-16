import UIKit

import Then
import SnapKit

import Model
import DesignSystem
import Common

final class MyMedalViewController: BaseViewController {
    private let myMedalView = MyMedalView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var dataSource = MyMedalDataSource(collectionView: myMedalView.collectionView, viewModel: viewModel)
    
    private let viewModel: MyMedalViewModel
    
    init(viewModel: MyMedalViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMedalView.collectionView.delegate = self
        
        viewModel.input.loadTrigger.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func loadView() {
        self.view = self.myMedalView
    }
    
    override func bindEvent() {
        super.bindEvent()
        
        myMedalView.backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        super.bindViewModelInput()
    }
    
    override func bindViewModelOutput() {
        super.bindViewModelOutput()
        
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { owner, error in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
        
        viewModel.output.sections
            .main
            .withUnretained(self)
            .sink { owner, sectionItems in
                owner.dataSource.reload(sectionItems)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .medalInfo(let viewModel):
                    owner.present(MedalInfoViewController(viewModel: viewModel), animated: true)
                }
            }
            .store(in: &cancellables)
    }
}

extension MyMedalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didSelectItem.send(indexPath)
    }
}

extension MyMedalViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch dataSource.sectionIdentifier(section: section)?.type {
        case .currentMedal:
            return .zero 
        default:
            return MedalHeaderView.size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .currentMedal:
            return MyMedalCollectionCell.size
        case .medal:
            return MedalCollectionCell.size
        default:
            return .zero
        }
    }
}
