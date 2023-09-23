import UIKit

import Common
import DesignSystem
import PanModal

final class ReportModalViewController: BaseViewController {
    private let reportModalView = ReportModalView()
    private let viewModel: ReportModalViewModel
    
    static func instance(viewModel: ReportModalViewModel) -> ReportModalViewController {
        return ReportModalViewController(viewModel: viewModel)
    }
    
    init(viewModel: ReportModalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = reportModalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportModalView.collectionView.dataSource = self
        reportModalView.collectionView.delegate = self
        reportModalView.collectionView.reloadData()
        reportModalView.updateCollectionViewHeight(itemCount: viewModel.output.reportReasons.count)
    }
    
    override func bindEvent() {
        reportModalView.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReportModalViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        reportModalView.reportButon
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableReport
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: reportModalView.reportButon)
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: ReportModalViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
}

extension ReportModalViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.reportReasons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let reason = viewModel.output.reportReasons[safe: indexPath.item] else { return BaseCollectionViewCell() }
        
        let cell: ReportReasonCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        cell.bind(reason)
        return cell
    }
}

extension ReportModalViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapReason.send(indexPath.item)
    }
}

extension ReportModalViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return reportModalView.collectionView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(192 + ReportModalView.Layout.calculateCollectionViewHeight(itemCount: viewModel.output.reportReasons.count))
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(192 + ReportModalView.Layout.calculateCollectionViewHeight(itemCount: viewModel.output.reportReasons.count))
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
