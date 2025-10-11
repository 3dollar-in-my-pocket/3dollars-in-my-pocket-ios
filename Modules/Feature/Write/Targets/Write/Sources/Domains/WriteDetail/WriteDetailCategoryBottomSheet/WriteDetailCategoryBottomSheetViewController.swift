import UIKit
import Combine

import Common
import DesignSystem
import Model
import SnapKit
import Log

import PanModal

final class WriteDetailCategoryBottomSheetViewController: BaseViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.WriteDetailCategoryBottomSheet.title
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Icons.deleteX.image, for: .normal)
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let editButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.WriteDetailCategoryBottomSheet.edit, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 14),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.backgroundColor = Colors.mainPink.color
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    override var screenName: ScreenName {
        return .writeDetailCategoryBottomSheet
    }
    
    private let viewModel: WriteDetailCategoryBottomSheetViewModel
    private lazy var datasource = WriteDetailCategoryBottomSheetDatasource(collectionView: collectionView, viewModel: viewModel)
    
    init(viewModel: WriteDetailCategoryBottomSheetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = datasource
        setupUI()
        bind()
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            titleLabel,
            closeButton,
            countLabel,
            containerScrollView,
            editButton
        ])
        
        containerScrollView.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.height.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(26)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(30)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        containerScrollView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(containerScrollView)
        }
        
        editButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            
            if UIUtils.bottomSafeAreaInset > 0 {
                $0.top.equalTo(containerScrollView.snp.bottom).offset(24)
            } else {
                $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            }
            $0.height.equalTo(48)
        }
    }
    
    private func bind() {
        editButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapEdit)
            .store(in: &cancellables)
        
        closeButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.datasource
            .main
            .sink { [weak self] sections in
                if let collectionViewHeight = self?.calculateCollectionViewHeight(from: sections) {
                    self?.containerScrollView.snp.updateConstraints {
                        $0.height.equalTo(collectionViewHeight)
                    }
                    self?.collectionView.snp.updateConstraints {
                        $0.height.equalTo(collectionViewHeight)
                    }
                    self?.containerScrollView.contentSize = CGSize(width: UIUtils.windowBounds.width, height: collectionViewHeight)
                }
                self?.datasource.reload(sections)
                DispatchQueue.main.async {
                    self?.selectCategories(from: sections)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.output.selectedCategoryCount, viewModel.output.setErrorCountState)
            .main
            .sink { [weak self] (count: Int, isError: Bool) in
                self?.updateCountLabel(count: count, isError: isError)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .sink { [weak self] route in
                self?.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func updateCountLabel(count: Int, isError: Bool) {
        let string = "(\(count)/10)"
        
        if isError {
            countLabel.textColor = Colors.mainRed.color
            countLabel.text = string
        } else {
            let coloredRange = (string as NSString).range(of: "\(count)")
            let attributedString = NSMutableAttributedString(string: string)
            attributedString.addAttribute(.foregroundColor, value: Colors.mainPink.color, range: coloredRange)
            countLabel.textColor = Colors.gray100.color
            countLabel.attributedText = attributedString
        }
    }
    
    private func selectCategories(from sections: [WriteDetailCategorySection]) {
        for (sectionIndex, section) in sections.enumerated() {
            section.items.enumerated().forEach { (index, item) in
                if item.isSelected {
                    collectionView.selectItem(at: IndexPath(item: index, section: sectionIndex), animated: false, scrollPosition: .top)
                }
            }
        }
    }
    
    private func calculateCollectionViewHeight(from sections: [WriteDetailCategorySection]) -> CGFloat {
        let contentInsets = collectionView.contentInset
        let availableWidth = UIUtils.windowBounds.width - contentInsets.left - contentInsets.right
        let minimumInteritemSpacing: CGFloat = 8
        let minimumLineSpacing: CGFloat = 8
        let headerHeight: CGFloat = 48
        
        var totalHeight: CGFloat = 0
        
        for section in sections {
            // Add header height
            totalHeight += headerHeight
            
            // Calculate items height for this section
            var currentLineWidth: CGFloat = 0
            var sectionHeight: CGFloat = 0
            var maxHeightInCurrentLine: CGFloat = 0
            
            for item in section.items {
                switch item {
                case .category(let category, _):
                    let itemSize = WriteDetailCategoryCell.Layout.calculateSize(category: category, isSmall: false)
                    
                    // Check if item fits in current line
                    let itemWidthWithSpacing = itemSize.width + (currentLineWidth > 0 ? minimumInteritemSpacing : 0)
                    
                    if currentLineWidth + itemWidthWithSpacing <= availableWidth {
                        // Item fits in current line
                        currentLineWidth += itemWidthWithSpacing
                        maxHeightInCurrentLine = max(maxHeightInCurrentLine, itemSize.height)
                    } else {
                        // Item doesn't fit, move to next line
                        if maxHeightInCurrentLine > 0 {
                            sectionHeight += maxHeightInCurrentLine + minimumLineSpacing
                        }
                        currentLineWidth = itemSize.width
                        maxHeightInCurrentLine = itemSize.height
                    }
                }
            }
            
            // Add height of the last line
            if maxHeightInCurrentLine > 0 {
                sectionHeight += maxHeightInCurrentLine
            }
            
            totalHeight += sectionHeight
        }
        
        return totalHeight
    }
}

// MARK: Route
extension WriteDetailCategoryBottomSheetViewController {
    private func handleRoute(_ route: WriteDetailCategoryBottomSheetViewModel.Route) {
        switch route {
        case .toast(let message):
            ToastManager.shared.show(message: message)
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        case .dismiss:
            dismiss(animated: true)
        }
    }
}

// MARK: PanModalPresentable
extension WriteDetailCategoryBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return containerScrollView
    }
    
    var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    var shortFormHeight: PanModalHeight {
        let collectionViewHeight = calculateCollectionViewHeight(from: viewModel.output.datasource.value)
        return .contentHeight(collectionViewHeight + 180)
    }
    
    var cornerRadius: CGFloat {
        return 24
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
}
