import Foundation
import UIKit
import Combine
import Then
import Common

final class ReportPollViewController: BaseViewController {

    private let reportPollView = ReportPollView()

    private lazy var dataSource = ReportPollDataSource(collectionView: reportPollView.collectionView)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reportPollView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.reloadData()
    }

    override func bindEvent() {
        super.bindEvent()

        reportPollView.closeButton
            .controlPublisher(for: .touchUpInside)
            .merge(
                with: reportPollView.backgroundButton
                    .controlPublisher(for: .touchUpInside)
            )
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
}
