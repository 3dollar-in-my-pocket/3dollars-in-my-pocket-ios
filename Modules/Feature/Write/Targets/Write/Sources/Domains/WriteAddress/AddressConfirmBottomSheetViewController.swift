import UIKit
import Combine

import Common
import DesignSystem
import Model

import PanModal

final class AddressConfirmBottomSheetViewController: BaseViewController {
    enum Layout {
        static func calculateHeight(viewModel: AddressConfirmBottomSheetViewModel) -> CGFloat {
            let defaultHeight: CGFloat = 246
            let stackViewHeight = calculateStoreListHeight(stores: viewModel.output.stores)
            
            return defaultHeight + stackViewHeight
        }
        
        static func calculateStoreListHeight(stores: [StoreWithExtraResponse]) -> CGFloat {
            var containerHeight: CGFloat = 52
            let maxRow = 3
            let row = min(maxRow, stores.count)
            containerHeight += StoreRowView.Layout.height * CGFloat(row)
            containerHeight += CGFloat(row - 1) * 3 // 간격
            
            if stores.count > maxRow {
                containerHeight += 17 // "외 2개" 라벨 높이
            }
            
            return containerHeight
        }
    }
    
    private let viewModel: AddressConfirmBottomSheetViewModel
    var onDismissed: (() -> Void)?
    
    // MARK: - UI
    private let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = Assets.iconClose.image
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semiBold.font(size: 20)
        label.textColor = Colors.gray100.color
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let storeListContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = Colors.gray20.color.cgColor
        return view
    }()
    
    private let storeListTitleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.AddressConfirmBottomSheet.nearStore
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.gray80.color
        return label
    }()
    
    private let storeListStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .fill
        return stack
    }()
    
    private let addressLabel: PaddingLabel = {
        let label = PaddingLabel(topInset: 12, bottomInset: 12, leftInset: 12, rightInset: 12)
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray70.color
        label.backgroundColor = Colors.gray10.color
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingHead
        return label
    }()
    
    private let confirmButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString(Strings.AddressConfirmBottomSheet.confirmButton, attributes: AttributeContainer([
            .font: Fonts.semiBold.font(size: 14),
            .foregroundColor: Colors.systemWhite.color
        ]))
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.backgroundColor = Colors.mainPink.color
        return button
    }()
    
    // MARK: - Init
    init(viewModel: AddressConfirmBottomSheetViewModel) {
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
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.systemWhite.color
        view.addSubViews([
            titleLabel,
            closeButton,
            storeListContainer,
            addressLabel,
            confirmButton
        ])
        storeListContainer.addSubViews([
            storeListTitleLabel,
            storeListStackView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(26)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-20)
        }
        
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(26)
            $0.width.height.equalTo(30)
        }
        
        storeListContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(Layout.calculateStoreListHeight(stores: viewModel.output.stores))
        }
        
        storeListTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.height.equalTo(18)
        }
        
        storeListStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.equalTo(storeListTitleLabel.snp.bottom).offset(8)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(storeListContainer.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        confirmButton.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        // 데이터 바인딩
        titleLabel.text = Strings.AddressConfirmBottomSheet.titleFormat(viewModel.output.stores.count)
        addressLabel.text = viewModel.output.address
        setupStoreList()
    }
    
    private func setupStoreList() {
        storeListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let stores = viewModel.output.stores
        let maxRow = 3
        for store in stores.prefix(min(maxRow, stores.count)) {
            let row = StoreRowView(store: store)
            storeListStackView.addArrangedSubview(row)
        }
        
        if stores.count > maxRow {
            let moreLabel = UILabel()
            moreLabel.text = Strings.AddressConfirmBottomSheet.moreFormat(stores.count - maxRow)
            moreLabel.font = Fonts.medium.font(size: 10)
            moreLabel.textColor = Colors.gray50.color
            moreLabel.textAlignment = .left
            moreLabel.snp.makeConstraints {
                $0.height.equalTo(14)
            }
            storeListStackView.addArrangedSubview(moreLabel)
        }
    }
    
    private func bind() {
        closeButton.tapPublisher
            .throttleClick()
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        confirmButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapConfirm)
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .sink(receiveValue: { [weak self] route in
                self?.handleRoute(route)
            })
            .store(in: &cancellables)
    }
}

// MARK: - Route
extension AddressConfirmBottomSheetViewController {
    private func handleRoute(_ route: AddressConfirmBottomSheetViewModel.Route) {
        switch route {
        case .dismiss:
            dismiss(animated: true) { [weak self] in
                self?.onDismissed?()
            }
        }
    }
}

// MARK: - StoreRowView
private final class StoreRowView: BaseView {
    enum Layout {
        static let height: CGFloat = 24
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.gray80.color
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    private let tagStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .trailing
        return stackView
    }()
    
    private let store: StoreWithExtraResponse
    
    init(store: StoreWithExtraResponse) {
        self.store = store
        super.init(frame: .zero)
        
        setupUI()
        setupTagStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.text = store.store.storeName
        addSubViews([
            titleLabel,
            tagStackView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(tagStackView.snp.leading).offset(-4)
        }
        
        tagStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(Layout.height)
        }
    }
    
    private func setupTagStackView() {
        if store.store.storeType == .bossStore {
            let badge = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
            badge.text = Strings.AddressConfirmBottomSheet.bossDirectly
            badge.font = Fonts.bold.font(size: 12)
            badge.textColor = Colors.mainPink.color
            badge.backgroundColor = Colors.pink100.color
            badge.layer.cornerRadius = 12
            badge.layer.masksToBounds = true
            tagStackView.addArrangedSubview(badge)
        }
        
        if let category = store.store.categories.first {
            let tagLabel = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 8, rightInset: 8)
            tagLabel.text = "#" + category.name
            tagLabel.font = Fonts.medium.font(size: 12)
            tagLabel.textColor = Colors.gray70.color
            tagLabel.backgroundColor = Colors.gray10.color
            tagLabel.layer.cornerRadius = 12
            tagLabel.layer.masksToBounds = true
            tagStackView.addArrangedSubview(tagLabel)
        }
    }
}

// MARK: - PanModal
extension AddressConfirmBottomSheetViewController: PanModalPresentable {
    var panScrollable: UIScrollView? { nil }
    
    var shortFormHeight: PanModalHeight { .contentHeight(Layout.calculateHeight(viewModel: viewModel)) }
    
    var longFormHeight: PanModalHeight { shortFormHeight }
    
    var cornerRadius: CGFloat { 24 }
    
    var showDragIndicator: Bool { false }
} 
