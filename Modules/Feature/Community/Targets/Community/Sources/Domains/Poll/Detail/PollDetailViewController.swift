import UIKit

import DesignSystem
import Then
import Common

final class PollDetailViewController: BaseViewController {

    private lazy var navigationBar = CommunityNavigationBar(rightButtons: [reportButton])

    private let reportButton = UIButton().then {
        $0.setImage(
            Icons.deletion.image
                .resizeImage(scaledTo: 24)
                .withTintColor(Colors.mainRed.color),
            for: .normal
        )
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
    }

    private let writeCommentView = PollDetailWriteCommentView()

    private lazy var dataSource = PollDetailDataSource(collectionView: collectionView)

    private let viewModel: PollDetailViewModel

    init(_ viewModel: PollDetailViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.input.firstLoad.send()
    }

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color

        view.addSubViews([
            navigationBar,
            collectionView,
            writeCommentView
        ])

        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(writeCommentView.snp.top)
        }

        writeCommentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        addKeyboardObservers()
    }

    override func bindEvent() {
        super.bindEvent()

        navigationBar.backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)

        // Input
        reportButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReportButton)
            .store(in: &cancellables)

        writeCommentView.writeButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapWirteCommentButton)
            .store(in: &cancellables)

        writeCommentView.didChangeText
            .subscribe(viewModel.input.comment)
            .store(in: &cancellables)

        // Output
        viewModel.output.showLoading
            .removeDuplicates()
            .main
            .sink { LoadingManager.shared.showLoading(isShow: $0) }
            .store(in: &cancellables)

        viewModel.output.showToast
            .main
            .sink { ToastManager.shared.show(message: $0) }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .report(let viewModel):
                    let vc = ReportPollViewController(viewModel)
                    owner.present(vc, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)

        viewModel.output.dataSource
            .main
            .withUnretained(self)
            .sink { owner, sections in
                owner.dataSource.reloadData(sections)
            }
            .store(in: &cancellables)
    }

    private func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }

    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ sender: Notification) {
        guard let userInfo = sender.userInfo as? [String: Any] else { return }
        guard let keyboardFrame
                = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let window = UIApplication.shared.windows.first
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        UIView.animate(withDuration: 0.3) {
            self.writeCommentView.transform = CGAffineTransform(
                translationX: 0,
                y: -keyboardFrame.cgRectValue.height + bottomPadding
            )
        }
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.writeCommentView.transform = .identity
        }
    }
}

extension PollDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width

        switch dataSource.itemIdentifier(for: indexPath) {
        case .detail:
            return CGSize(width: width, height: PollDetailContentCell.Layout.height)
        case .comment:
            return CGSize(width: width, height: PollDetailCommentCell.Layout.height)
        default:
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width

        switch dataSource.sectionIdentifier(section: section)?.type {
        case .comment:
            return CGSize(width: width, height: PollDetailCommentHeaderView.Layout.height)
        default:
            return .zero
        }
    }
}

extension PollDetailViewController: UICollectionViewDelegate {

}
