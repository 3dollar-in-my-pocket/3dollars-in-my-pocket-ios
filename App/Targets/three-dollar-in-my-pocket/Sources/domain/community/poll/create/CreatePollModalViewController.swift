import UIKit

import RxSwift

final class CreatePollModalViewController: BaseViewController {
    private let modalView = CreatePollModalView()

    init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overCurrentContext
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.modalView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let parentView = self.presentingViewController?.view {
            DimManager.shared.showDim(targetView: parentView)
        }
    }

    override func bindEvent() {
        super.bindEvent()

        modalView.cancelButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)

        modalView.backgroundView
            .gesture(.tap())
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)

        DimManager.shared.hideDim()
    }
}
