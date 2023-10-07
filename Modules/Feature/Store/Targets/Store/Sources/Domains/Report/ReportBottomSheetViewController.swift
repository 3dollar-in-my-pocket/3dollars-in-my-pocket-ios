import UIKit

import Common
import DesignSystem
import PanModal

final class ReportBottomSheetViewController: BaseViewController {
    private let reportBottomSheet = ReportBottomSheet()
    private let viewModel: ReportBottomSheetViewModel
    
    static func instance(viewModel: ReportBottomSheetViewModel) -> ReportBottomSheetViewController {
        return ReportBottomSheetViewController(viewModel: viewModel)
    }
    
    init(viewModel: ReportBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = reportBottomSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportBottomSheet.collectionView.dataSource = self
        reportBottomSheet.collectionView.delegate = self
        reportBottomSheet.collectionView.reloadData()
        reportBottomSheet.updateCollectionViewHeight(itemCount: viewModel.output.reportReasons.count)
    }
    
    override func bindEvent() {
        reportBottomSheet.closeButton
            .controlPublisher(for: .touchUpInside)
            .withUnretained(self)
            .sink { (owner: ReportBottomSheetViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelInput() {
        reportBottomSheet.reportButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReport)
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.isEnableReport
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: reportBottomSheet.reportButton)
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (owner: ReportBottomSheetViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }
}

extension ReportBottomSheetViewController: UICollectionViewDataSource {
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

extension ReportBottomSheetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.didTapReason.send(indexPath.item)
    }
}

extension ReportBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return reportBottomSheet.collectionView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(192 + ReportBottomSheet.Layout.calculateCollectionViewHeight(itemCount: viewModel.output.reportReasons.count))
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(192 + ReportBottomSheet.Layout.calculateCollectionViewHeight(itemCount: viewModel.output.reportReasons.count))
    }
    
    var cornerRadius: CGFloat {
        return 16
    }
    
    var showDragIndicator: Bool {
        return false
    }
}
