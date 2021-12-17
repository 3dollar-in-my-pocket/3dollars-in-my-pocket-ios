import UIKit

final class MedalInfoViewController: BaseVC, MedalInfoCoordinator {
    private let medalInfoView = MedalInfoView()
    private let viewModel = MedalInfoViewModel(medalContext: MedalContext.shared)
    private weak var coordinator: MedalInfoCoordinator?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static func instance() -> MedalInfoViewController {
        return MedalInfoViewController(nibName: nil, bundle: nil).then {
            $0.modalPresentationStyle = .overCurrentContext
        }
    }
    
    override func loadView() {
        self.view = self.medalInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coordinator = self
        self.viewModel.input.viewDidLoad.onNext(())
    }
    
    override func bindEvent() {
        self.medalInfoView.closeButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.coordinator?.dismiss()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindViewModelOutput() {
        self.viewModel.output.medals
            .asDriver(onErrorJustReturn: [])
            .drive(self.medalInfoView.tableView.rx.items(
                    cellIdentifier: MedalInfoTableViewCell.registerId,
                    cellType: MedalInfoTableViewCell.self
            )) { _, medal, cell in
                cell.bind(medal: medal)
            }
            .disposed(by: self.disposeBag)
    }
}
