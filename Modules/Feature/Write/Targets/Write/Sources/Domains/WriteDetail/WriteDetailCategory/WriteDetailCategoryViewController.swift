import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit

final class WriteDetailCategoryViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "음식 카테고리 선택"
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailInfo.next, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.backgroundColor = Colors.mainPink.color
        return button
    }()
    
    private let buttonBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.mainPink.color
        return view
    }()
    
    private let viewModel: WriteDetailCategoryViewModel
    private lazy var datasource = WriteDetailCategoryDatasource(collectionView: collectionView, viewModel: viewModel)
    
    init(viewModel: WriteDetailCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        viewModel.input.viewDidLoad.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            titleLabel,
            countLabel,
            collectionView,
            nextButton,
            buttonBackground
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.centerY.equalTo(titleLabel)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
    }
    
    private func setupNavigationBar() {
        title = "가게 제보"
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.updateProgress(0.5)
        navigationController.setProgressHidden(false)
        
        let closeImage = DesignSystemAsset.Icons.close.image
            .resizeImage(scaledTo: 24)
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.white)
        let closeButtonItem = UIBarButtonItem(
            image: closeImage,
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
        closeButtonItem.tintColor = Colors.gray100.color
        navigationItem.setAutoInsetRightBarButtonItem(closeButtonItem)
    }
    
    private func bind() {
        nextButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapNext)
            .store(in: &cancellables)
        
        viewModel.output.datasource
            .main
            .sink { [weak self] sections in
                self?.datasource.reload(sections)
            }
            .store(in: &cancellables)
        
        viewModel.output.selectedCategoryCount
            .main
            .sink { [weak self] count in
                self?.countLabel.text = "(\(count)/10)"
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.output.selectedCategoryCount, viewModel.output.setErrorCountState)
            .main
            .sink { [weak self] (selectedCategory: Int, isErrorState: Bool) in
                self?.updateSelectedCategoryCount(isErrorState, selectedCategoryCount: selectedCategory)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func updateSelectedCategoryCount(_ isError: Bool, selectedCategoryCount: Int) {
        let categoryCount = viewModel.output.selectedCategoryCount.value
        let string = "(\(categoryCount)/10)"
        let attributedString = NSMutableAttributedString(string: string)
        
        if isError {
            let range = (string as NSString).range(of: string)
            attributedString.addAttribute(.foregroundColor, value: Colors.mainRed.color, range: range)
        } else {
            let range = (string as NSString).range(of: "\(categoryCount)")
            
            if categoryCount == 0 {
                attributedString.addAttribute(.foregroundColor, value: Colors.gray50.color, range: range)
            } else {
                attributedString.addAttribute(.foregroundColor, value: Colors.mainPink.color, range: range)
            }
        }
        countLabel.attributedText = attributedString
    }
    
    @objc private func didTapClose() {
        presentDismissModal()
    }
}

// MARK: Route
extension WriteDetailCategoryViewController {
    private func handleRoute(_ route: WriteDetailCategoryViewModel.Route) {
        switch route {
        case .toast(let message):
            ToastManager.shared.show(message: message)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
    
    private func presentDismissModal() {
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }
}
