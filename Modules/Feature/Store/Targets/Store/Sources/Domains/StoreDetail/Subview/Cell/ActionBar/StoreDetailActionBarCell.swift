import UIKit

import Common
import Model

final class StoreDetailActionBarCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 74 + topPadding
        static let topPadding: CGFloat = 20
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray0.color
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 6
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        return stackView
    }()
    
    private let favoriteButton = ActionButton(.save)
    
    private let shareButton = ActionButton(.share)
    
    private let navigationButton = ActionButton(.navigation)
    
    private let reviewButton = ActionButton(.review)

    private let snsButton = ActionButton(.sns)

    override func setup() {
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func setupUI() {
        addSubViews([
            containerView,
            stackView
        ])

        favoriteButton.snp.makeConstraints {
            $0.size.equalTo(ActionButton.Layout.size)
        }

        shareButton.snp.makeConstraints {
            $0.size.equalTo(ActionButton.Layout.size)
        }

        navigationButton.snp.makeConstraints {
            $0.size.equalTo(ActionButton.Layout.size)
        }

        reviewButton.snp.makeConstraints {
            $0.size.equalTo(ActionButton.Layout.size).priority(.high)
        }

        snsButton.snp.makeConstraints {
            $0.size.equalTo(ActionButton.Layout.size)
        }
        
        containerView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.right.equalToSuperview()
            $0.height.equalTo(Layout.height)
        }
        
        stackView.snp.makeConstraints {
            $0.left.equalTo(containerView).offset(12)
            $0.top.equalTo(containerView).offset(16)
            $0.bottom.equalTo(containerView).offset(-16)
            $0.right.equalTo(containerView).offset(-12)
        }
    }
    
    private func addDivider() {
        let divider = UIView()
        divider.backgroundColor = Colors.gray10.color
        divider.snp.makeConstraints {
            $0.width.equalTo(1).priority(.high)
            $0.height.equalTo(32).priority(.high)
        }
        
        stackView.addArrangedSubview(divider)
    }
    
    func bind(viewModel: StoreDetailActionBarCellViewModel) {
        setData(data: viewModel.output.data, storeType: viewModel.output.storeType)
        
        favoriteButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in StoreDetailActionBarItemType.save }
            .subscribe(viewModel.input.didTapActionButton)
            .store(in: &cancellables)
        
        shareButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in StoreDetailActionBarItemType.share }
            .subscribe(viewModel.input.didTapActionButton)
            .store(in: &cancellables)
        
        navigationButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in StoreDetailActionBarItemType.navigation }
            .subscribe(viewModel.input.didTapActionButton)
            .store(in: &cancellables)
        
        reviewButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in StoreDetailActionBarItemType.review }
            .subscribe(viewModel.input.didTapActionButton)
            .store(in: &cancellables)
        
        snsButton
            .controlPublisher(for: .touchUpInside)
            .map { _ in StoreDetailActionBarItemType.sns }
            .subscribe(viewModel.input.didTapActionButton)
            .store(in: &cancellables)
        
        viewModel.output.favoriteStatus
            .main
            .sink(receiveValue: { [weak self] isFavorite in
                self?.favoriteButton.isSelected = isFavorite
            })
            .store(in: &cancellables)
        
        viewModel.output.favoriteCount
            .main
            .sink { [weak self] favoriteCount in
                self?.favoriteButton.setCount(favoriteCount)
            }
            .store(in: &cancellables)
    }
    
    private func setData(data: StoreActionBarSectionResponse, storeType: StoreType) {
        let menuTypeList: [StoreDetailActionBarItemType]
        
        switch storeType {
        case .userStore:
            menuTypeList = [.save, .share, .navigation, .review]
        case .bossStore:
            menuTypeList = [.save, .share, .navigation, .sns]
        case .unknown:
            menuTypeList = []
        }
        
        setupStackView(menuTypeList: menuTypeList)
    }
    
    private func setupStackView(menuTypeList: [StoreDetailActionBarItemType]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        menuTypeList.forEach {
            switch $0 {
            case .save:
                stackView.addArrangedSubview(favoriteButton)
                addDivider()
            case .share:
                stackView.addArrangedSubview(shareButton)
                addDivider()
            case .navigation:
                stackView.addArrangedSubview(navigationButton)
                addDivider()
            case .review:
                stackView.addArrangedSubview(reviewButton)
            case .sns:
                stackView.addArrangedSubview(snsButton)
            }
        }
    }
}

enum StoreDetailActionBarItemType {
    case save
    case share
    case navigation
    case review
    case sns

    var icon: UIImage {
        switch self {
        case .save:
            return Icons.bookmarkLine.image.withTintColor(Colors.systemBlack.color)

        case .share:
            return Icons.share.image.withTintColor(Colors.systemBlack.color)

        case .navigation:
            return Icons.locationLine.image.withTintColor(Colors.systemBlack.color)

        case .review:
            return Icons.writeLine.image.withTintColor(Colors.systemBlack.color)

        case .sns:
            return Icons.link.image.withTintColor(Colors.systemBlack.color)
        }
    }

    var text: String {
        switch self {
        case .save:
            return ""

        case .share:
            return Strings.StoreDetail.Menu.share

        case .navigation:
            return Strings.StoreDetail.Menu.navigation

        case .review:
            return Strings.StoreDetail.Menu.review

        case .sns:
            return "SNS"
        }
    }
}

extension StoreDetailActionBarCell {
    final class ActionButton: UIControl {
        typealias ItemType = StoreDetailActionBarItemType

        enum Layout {
            static let size = CGSize(
                width: (UIScreen.main.bounds.width - 64 - 36)/4,
                height: 42
            )
        }
        
        var icon = UIImageView()
        
        let label: UILabel = {
            let label = UILabel()
            label.font = Fonts.medium.font(size: 12)
            label.textColor = Colors.gray100.color
            label.textAlignment = .center
            return label
        }()
        
        override var isSelected: Bool {
            didSet {
                switch type {
                case .save:
                    if isSelected {
                        icon.image = Icons.bookmarkSolid.image.withTintColor(Colors.mainRed.color)
                    } else {
                        icon.image = Icons.bookmarkLine.image.withTintColor(Colors.systemBlack.color)
                    }
                    
                default:
                    return
                }
            }
        }
        
        private let type: ItemType
        
        init(_ type: ItemType) {
            self.type = type
            super.init(frame: .zero)
            
            icon.image = type.icon
            label.text = type.text
            
            setup()
            bindConstraints()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setCount(_ count: Int) {
            label.text = "\(count)"
        }
        
        private func setup() {
            addSubViews([
                icon,
                label
            ])
        }
        
        private  func bindConstraints() {
            icon.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview()
                $0.size.equalTo(20)
            }
            
            label.snp.makeConstraints {
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.top.equalTo(icon.snp.bottom).offset(4)
            }
        }
    }
}
