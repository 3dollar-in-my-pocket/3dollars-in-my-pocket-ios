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
    }

    private let writeCommentView = WriteCommentView()

    private lazy var dataSource = PollDetailDataSource(collectionView: collectionView)

    init() {
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func bindEvent() {
        super.bindEvent()

        reportButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                let vc = ReportPollViewController()
                owner.present(vc, animated: true, completion: nil)
            }
            .store(in: &cancellables)

        navigationBar.backButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, index in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
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

        dataSource.reloadData()
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

// MARK: TextField
final class WriteCommentView: BaseView {
    enum Layout {
        enum Placeholder {
            static let text = "의견 달기"
            static let color = Colors.gray50.color
        }

        static let textColor = Colors.gray100.color
    }

    let lineView = UIView().then {
        $0.backgroundColor = Colors.gray30.color
    }

    lazy var textView = UITextView().then {
        $0.backgroundColor = Colors.gray10.color
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.clear.cgColor
        $0.isScrollEnabled = false
        $0.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        $0.text = Layout.Placeholder.text
        $0.textColor = Layout.Placeholder.color
        $0.font = Fonts.regular.font(size: 14)
        $0.keyboardDismissMode = .interactive
        $0.delegate = self
    }

    let writeButton = UIButton().then {
        $0.setImage(Icons.writeSolid.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.mainPink.color), for: .normal)
        $0.setImage(Icons.writeSolid.image
            .resizeImage(scaledTo: 20)
            .withTintColor(Colors.gray40.color), for: .disabled)
        $0.contentEdgeInsets = .init(top: 16, left: 12, bottom: 20, right: 16)
    }

    override func setup() {
        super.setup()

        backgroundColor = Colors.systemWhite.color

        addSubViews([lineView, textView, writeButton])
    }

    override func bindConstraints() {
        super.bindConstraints()

        lineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        textView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(48)
        }

        writeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }
    }
}

extension WriteCommentView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = Colors.mainPink.color.cgColor
        if textView.text == Layout.Placeholder.text {
            textView.text.removeAll()
        }
        textView.textColor = Layout.textColor
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        writeButton.isEnabled = textView.text.isNotEmpty
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.layer.borderColor = UIColor.clear.cgColor
        textView.textColor = Layout.textColor

        if textView.text.isEmpty {
            textView.text = Layout.Placeholder.text
            textView.textColor = Layout.Placeholder.color
        }

        return true
    }
}
