import UIKit

import Common
import DesignSystem

final class StoreDetailOverviewMenuView: BaseView {
    enum Layout {
        static let height: CGFloat = 74
    }
    
    let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
    }
    
    let stackView = UIStackView().then {
        $0.spacing = 6
        $0.axis = .horizontal
        $0.distribution = .equalCentering
        $0.alignment = .center
    }
    
    let favoriteButton = ItemButton(.save)
    
    let shareButton = ItemButton(.share)
    
    let navigationButton = ItemButton(.navigation)
    
    let reviewButton = ItemButton(.review)

    let snsButton = ItemButton(.sns)

    override func setup() {
        addSubViews([
            containerView,
            stackView
        ])

        favoriteButton.snp.makeConstraints {
            $0.size.equalTo(ItemButton.Layout.size)
        }

        shareButton.snp.makeConstraints {
            $0.size.equalTo(ItemButton.Layout.size)
        }

        navigationButton.snp.makeConstraints {
            $0.size.equalTo(ItemButton.Layout.size)
        }

        reviewButton.snp.makeConstraints {
            $0.size.equalTo(ItemButton.Layout.size).priority(.high)
        }

        snsButton.snp.makeConstraints {
            $0.size.equalTo(ItemButton.Layout.size)
        }
    }
    
    override func bindConstraints() {
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

    func bind(_ menuList: [StoreDetailOverviewMenuItemType]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        menuList.forEach {
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

enum StoreDetailOverviewMenuItemType {
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

extension StoreDetailOverviewMenuView {
    final class ItemButton: UIControl {
        typealias ItemType = StoreDetailOverviewMenuItemType

        enum Layout {
            static let size = CGSize(
                width: (UIScreen.main.bounds.width - 64 - 36)/4,
                height: 42
            )
        }
        
        var icon = UIImageView()
        
        let label = UILabel().then {
            $0.font = Fonts.medium.font(size: 12)
            $0.textColor = Colors.gray100.color
            $0.textAlignment = .center
        }
        
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
