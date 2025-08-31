import UIKit
import Combine

import Common
import DesignSystem
import Model

final class WriteDetailMenuViewController: BaseViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = Colors.gray10.color
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.layoutMargins = .init(top: 0, left: 0, bottom: 48, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        return stackView
    }()
    
    private let titleLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 20, bottomInset: 0, leftInset: 20, rightInset: 20)
        label.font = Fonts.bold.font(size: 24)
        label.textColor = Colors.gray100.color
        
        let string = Strings.WriteDetailMenu.title
        let range = (string as NSString).range(of: Strings.WriteDetailMenu.titleSmallRange)
        let attributedString = NSMutableAttributedString(string: string)
        
        attributedString.addAttribute(.font, value: Fonts.bold.font(size: 16), range: range)
        attributedString.addAttribute(.foregroundColor, value: Colors.gray50.color, range: range)
        label.attributedText = attributedString
        label.textAlignment = .left
        label.backgroundColor = Colors.systemWhite.color
        return label
    }()
    
    private let categoryLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 8, bottomInset: 0, leftInset: 20, rightInset: 20)
        label.font = Fonts.regular.font(size: 14)
        label.text = Strings.WriteDetailMenu.category
        label.textColor = Colors.gray80.color
        label.textAlignment = .left
        label.backgroundColor = Colors.systemWhite.color
        return label
    }()
    
    private let categoryCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 6
        layout.minimumInteritemSpacing = 6
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.systemWhite.color
        collectionView.contentInset = UIEdgeInsets(top: 4, left: 20, bottom: 16, right: 20)
        return collectionView
    }()
    
    private let menuCategoryView = MenuCategoryView()
    
    private let buttonContainerView = UIView()

    private let addMenuButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = Colors.gray90.color
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.addMenu, attributes: AttributeContainer([
            .font: Fonts.bold.font(size: 12),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    private let skipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.skip, attributes: AttributeContainer([
            .font: Fonts.medium.font(size: 16),
            .foregroundColor: Colors.gray70.color
        ]))
        config.image = Icons.arrowRight.image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(Colors.gray70.color)
            .resizeImage(scaledTo: 16)
        config.imagePadding = 4
        
        let button = UIButton(configuration: config)
        return button
    }()

    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailMenu.next, attributes: AttributeContainer([
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

    private let viewModel: WriteDetailMenuViewModel
    private var categoryDatasource: [StoreFoodCategoryResponse] = []
    private var gradientLayer: CAGradientLayer?
    private var currentInset: CGFloat = .zero
    private let tapBackground = UITapGestureRecognizer()
    
    init(viewModel: WriteDetailMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        addKeyboardObservers()
        bind()
        viewModel.input.viewDidLoad.send(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradientToSkipButton()
    }

    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            scrollView,
            skipButton,
            nextButton,
            buttonBackground
        ])
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(categoryCollectionView)
        stackView.addArrangedSubview(menuCategoryView)
        stackView.addArrangedSubview(buttonContainerView, previousSpace: 16)
        
        buttonContainerView.addSubview(addMenuButton)
        buttonContainerView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        addMenuButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIUtils.windowBounds.width)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.height.equalTo(0)
        }
        
        addMenuButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
        
        skipButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top)
            $0.height.equalTo(48)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(64)
        }
        
        buttonBackground.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func setupNavigationBar() {
        guard let navigationController = navigationController as? WriteNavigationController else { return }
        navigationController.isNavigationBarHidden = false
        if viewModel.output.afterCreatedStore {
            title = Strings.WriteDetailMenu.Navigation.Title.afterCreated
            navigationController.setProgressHidden(true)
            navigationItem.rightBarButtonItem = nil
        } else {
            title = Strings.WriteDetailMenu.Navigation.Title.normal
            navigationController.updateProgress(0.75)
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
    }

    private func bind() {
        scrollView.addGestureRecognizer(tapBackground)
        tapBackground.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
            }
            .store(in: &cancellables)
        
        bindAfterCreateStore(viewModel.output.afterCreatedStore)
        addMenuButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapAddMenu)
            .store(in: &cancellables)
        
        skipButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapSkip)
            .store(in: &cancellables)
        
        nextButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapNext)
            .store(in: &cancellables)
        
        Publishers.Zip(viewModel.output.categories, viewModel.output.selectedCategoryIndex)
            .first()
            .sink { [weak self] (categories, index) in
                self?.loadCategories(categories: categories, selectedIndex: index)
            }
            .store(in: &cancellables)
        
        viewModel.output.categories
            .dropFirst()
            .main
            .sink { [weak self] (categories: [StoreFoodCategoryResponse]) in
                guard let self else { return }
                loadCategories(categories: categories, selectedIndex: viewModel.output.selectedCategoryIndex.value)
            }
            .store(in: &cancellables)
        
        viewModel.output.selectedCategoryIndex
            .withLatestFrom(viewModel.output.categories) { ($0, $1) }
            .main
            .sink { [weak self] (index, categories) in
                if let category = categories[safe: index] {
                    self?.menuCategoryView.bind(category: category)
                }
                self?.categoryCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
            .store(in: &cancellables)
        
        viewModel.output.menus
            .main
            .sink { [weak self] viewModels in
                self?.refreshMenus(viewModels: viewModels)
            }
            .store(in: &cancellables)
        
        viewModel.output.addMenus
            .main
            .sink { [weak self] viewModel in
                self?.addMenus(viewModel: viewModel)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func bindAfterCreateStore(_ afterCreateStore: Bool) {
        let string = afterCreateStore ? Strings.WriteDetailMenu.finish : Strings.WriteDetailMenu.next
        nextButton.configuration?.attributedTitle = AttributedString(string, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 16),
            .foregroundColor: Colors.systemWhite.color
        ]))
        skipButton.isHidden = afterCreateStore
    }
    
    private func setupCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register([
            WriteDetailCategoryCell.self,
            WriteDetailMenuEditCategoryCell.self,
            UICollectionViewCell.self
        ])
    }
    
    private func updateCategoryCollectionViewHeight(categories: [StoreFoodCategoryResponse]) {
        var height: CGFloat = 32
        var totalWidth: CGFloat = 0
        
        for category in categories {
            let cellWidth = WriteDetailCategoryCell.Layout.calculateSize(category: category).width
            
            if totalWidth + cellWidth > UIUtils.windowBounds.width - 40 {
                height += 32 + 6 // 32는 셀 높이, 6은 셀 사이의 간격
                totalWidth = cellWidth
            } else {
                totalWidth += cellWidth + 6 // 6은 셀 사이의 간격
            }
        }
        
        if totalWidth + 120 > UIUtils.windowBounds.width - 40 {
            height += 32 + 6 // 다음 줄로 넘어갈 때 높이 추가
        }
        
        categoryCollectionView.snp.updateConstraints {
            $0.height.equalTo(height + 20)
        }
    }
    
    private func loadCategories(categories: [StoreFoodCategoryResponse], selectedIndex: Int) {
        if let category = categories[safe: selectedIndex] {
            menuCategoryView.bind(category: category)
        }
        
        categoryDatasource = categories
        updateCategoryCollectionViewHeight(categories: categories)
        categoryCollectionView.reloadData()
        
        DispatchQueue.main.async { [weak self] in
            self?.categoryCollectionView.selectItem(at: IndexPath(item: selectedIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func refreshMenus(viewModels: [MenuInputViewModel]) {
        stackView.arrangedSubviews.filter { $0 is MenuInputView }.forEach { $0.removeFromSuperview() }
        buttonContainerView.removeFromSuperview()
        
        for viewModel in viewModels {
            let view = MenuInputView(viewModel: viewModel)
            stackView.addArrangedSubview(view)
        }
        stackView.addArrangedSubview(buttonContainerView, previousSpace: 16)
    }
    
    private func addMenus(viewModel: MenuInputViewModel) {
        buttonContainerView.removeFromSuperview()
        let menuInput = MenuInputView(viewModel: viewModel)
        
        stackView.addArrangedSubview(menuInput)
        stackView.addArrangedSubview(buttonContainerView, previousSpace: 16)
    }
    
    private func applyGradientToSkipButton() {
        guard gradientLayer.isNil else { return }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            Colors.systemWhite.color.withAlphaComponent(0.0).cgColor,
            Colors.systemWhite.color.withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 위쪽 중앙
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 아래쪽 중앙
        gradientLayer.frame = skipButton.bounds

        skipButton.layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard currentInset == .zero else { return }
        let keyboardHeight = UIUtils.mapNotificationToKeyboardHeight(notification: notification)
        let inset = keyboardHeight > 0 ? (keyboardHeight - view.safeAreaInsets.bottom) : 0
        currentInset = inset
        scrollView.contentInset.bottom += inset
    }

    @objc private func keyboardWillHide(_ sender: Notification) {
        scrollView.contentInset.bottom -= currentInset
        currentInset = .zero
    }
    
    @objc private func didTapClose() {
        presentDismissModal()
    }
}

// MARK: - Route
extension WriteDetailMenuViewController {
    private func handleRoute(_ route: WriteDetailMenuViewModel.Route) {
        switch route {
        case .presentCategoryBottomSheet(let viewModel):
            presentCategoryBottomSheet(viewModel: viewModel)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .pop:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func presentDismissModal() {
        let viewController = WriteCloseViewController { [weak self] in
            self?.dismiss(animated: true)
        }
        present(viewController, animated: true)
    }
    
    private func presentCategoryBottomSheet(viewModel: WriteDetailCategoryBottomSheetViewModel) {
        let viewController = WriteDetailCategoryBottomSheetViewController(viewModel: viewModel)
        presentPanModal(viewController)
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension WriteDetailMenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryDatasource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == categoryDatasource.count {
            let cell: WriteDetailMenuEditCategoryCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            return cell
        } else {
            guard let category = categoryDatasource[safe: indexPath.item] else { return UICollectionViewCell() }
            let cell: WriteDetailCategoryCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.bind(category: category, isSmall: true)
            return cell
        }
    }
}

extension WriteDetailMenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.selectCategory.send(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == categoryDatasource.count {
            return WriteDetailMenuEditCategoryCell.Layout.size
        } else {
            guard let category = categoryDatasource[safe: indexPath.item] else { return .zero }
            return WriteDetailCategoryCell.Layout.calculateSize(category: category, isSmall: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if indexPath.item == categoryDatasource.count {
            viewModel.input.didTapEditCategory.send(())
            return false
        } else {
            return true
        }
    }
}
