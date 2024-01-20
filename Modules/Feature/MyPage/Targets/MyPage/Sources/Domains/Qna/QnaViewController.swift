import UIKit
import MessageUI
import DeviceKit

import DesignSystem
import Common

public final class QnaViewController: BaseViewController {
    private let qnaView = QnaView()
    private let viewModel: QnaViewModel
    
    public init(viewModel: QnaViewModel = QnaViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = qnaView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        qnaView.collectionView.dataSource = self
        qnaView.collectionView.delegate = self
    }
    
    public override func bindEvent() {
        qnaView.backButton.controlPublisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: QnaViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    public override func bindViewModelOutput() {
        viewModel.output.route
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: QnaViewController, route: QnaViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func handleRoute(_ route: QnaViewModel.Route) {
        switch route {
        case .pushFAQ:
            pushFAQ()
        case .presentMail(let nickname):
            Environment.appModuleInterface.presentMailComposeViewController(
                nickname: nickname,
                targetViewController: self
            )
        }
    }
    
    private func pushFAQ() {
        print("💜push faq")
    }
}

extension QnaViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.datasource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cellType = viewModel.output.datasource[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: QnaCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        cell.bind(cellType: cellType)
        return cell
    }
}

extension QnaViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapCell.send(indexPath.item)
    }
}

extension QnaViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true, completion: nil)
    }
}
