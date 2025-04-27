import UIKit

import Common
import Model

final class FeedCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(feed: FeedResponse) -> CGFloat {
            return feed.calculateContentHeight()
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.layoutMargins = .init(top: 20, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
    }
    
    override func setup() {
        contentView.backgroundColor = Colors.systemWhite.color
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
        }
        
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = Colors.systemBlack.color.cgColor
        contentView.layer.shadowOpacity = 0.06
        contentView.layer.shadowOffset = .zero
    }
    
    func bind(feed: FeedResponse) {
        if let category = feed.category {
            bindCategory(category: category, updatedAt: feed.updatedAt)
        }
        
        if let header = feed.header {
            bindHeader(header: header)
        }
        
        if let body = feed.body {
            bindBody(body: body)
        }
    }
    
    private func bindCategory(category: FeedCategoryResponse, updatedAt: String) {
        let categoryView = FeedCellCategoryView()
        categoryView.bind(category: category, updatedAt: updatedAt)
        
        stackView.addArrangedSubview(categoryView)
        categoryView.snp.makeConstraints {
            $0.height.equalTo(FeedCellCategoryView.Layout.height)
        }
    }
    
    private func bindHeader(header: FeedHeaderResponse) {
        if let generalHeader = header as? GeneralFeedHeaderResponse {
            let headerView = FeedCellHeaderView()
            headerView.bind(header: generalHeader)
            stackView.addArrangedSubview(headerView, previousSpace: 16)
            headerView.snp.makeConstraints {
                $0.height.equalTo(FeedCellHeaderView.Layout.height)
            }
        }
    }
    
    private func bindBody(body: FeedBodyResponse) {
        switch body {
        case let body as ContentWithTitleFeedBodyResponse:
            let bodyView = FeedCellContentWithTitleBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView, previousSpace: 12)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentWithTitleBodyView.Layout.calculateHeight(body: body))
            }
        case let body as ContentWithTitleAndImagesFeedBodyResponse:
            let bodyView = FeedCellContentWithTitleAndImagesBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView, previousSpace: 12)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentWithTitleAndImagesBodyView.Layout.calculateHeight(body: body))
            }
        case let body as ContentWithImagesFeedBodyResponse:
            let bodyView = FeedCellContentWithImagesBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView, previousSpace: 12)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentWithImagesBodyView.Layout.calculateHeight(body: body))
            }
        case let body as ContentOnlyFeedBodyResponse:
            let bodyView = FeedCellContentOnlyBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView, previousSpace: 12)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentOnlyBodyView.Layout.height)
            }
        default:
            return
        }
    }
}

extension FeedResponse {
    func calculateContentHeight() -> CGFloat {
        var height: CGFloat = 0
        
        height += 16 // Top padding
        height += calculateCategoryHeight()
        
        height += 16 // Header top padding
        height += calculateHeaderHeight()
        
        if body.isNotNil {
            height += 12 // Body top padding
            height += calculateBodyHeight()
        }
        
        height += 16 // Bottom padding
        return height
    }
    
    func calculateCategoryHeight() -> CGFloat {
        return FeedCellCategoryView.Layout.height
    }
    
    func calculateHeaderHeight() -> CGFloat {
        var headerHeight: CGFloat = 0
        
        if let _ = header as? GeneralFeedHeaderResponse {
            headerHeight = FeedCellHeaderView.Layout.height
        }
        
        return headerHeight
    }
    
    func calculateBodyHeight() -> CGFloat {
        var bodyHeight: CGFloat = 0
        
        switch body {
        case let body as ContentWithTitleFeedBodyResponse:
            bodyHeight = FeedCellContentWithTitleBodyView.Layout.calculateHeight(body: body)
        case let body as ContentWithTitleAndImagesFeedBodyResponse:
            bodyHeight = FeedCellContentWithTitleAndImagesBodyView.Layout.calculateHeight(body: body)
        case let body as ContentWithImagesFeedBodyResponse:
            bodyHeight = FeedCellContentWithImagesBodyView.Layout.calculateHeight(body: body)
        case let _ as ContentOnlyFeedBodyResponse:
            bodyHeight = FeedCellContentOnlyBodyView.Layout.height
        default:
            bodyHeight = 0
        }
        return bodyHeight
    }
}
