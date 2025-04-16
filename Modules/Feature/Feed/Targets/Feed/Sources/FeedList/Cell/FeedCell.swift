import UIKit

import Common
import Model

final class FeedCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(feed: FeedResponse) -> CGFloat {
            return .zero
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
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
        stackView.setCustomSpacing(16, after: categoryView)
        categoryView.snp.makeConstraints {
            $0.height.equalTo(FeedCellCategoryView.Layout.height)
        }
    }
    
    private func bindHeader(header: FeedHeaderResponse) {
        if let generalHeader = header as? GeneralFeedHeaderResponse {
            let headerView = FeedCellHeaderView()
            headerView.bind(header: generalHeader)
            stackView.addArrangedSubview(headerView)
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
            stackView.addArrangedSubview(bodyView)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentWithTitleBodyView.Layout.calculateHeight(body: body))
            }
        case let body as ContentWithTitleAndImagesFeedBodyResponse:
            let bodyView = FeedCellContentWithTitleAndImagesBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentWithTitleAndImagesBodyView.Layout.calculateHeight(body: body))
            }
        case let body as ContentWithImagesFeedBodyResponse:
            let bodyView = FeedCellContentWithImagesBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentWithImagesBodyView.Layout.calculateHeight(body: body))
            }
        case let body as ContentOnlyFeedBodyResponse:
            let bodyView = FeedCellContentOnlyBodyView()
            bodyView.bind(body: body)
            stackView.addArrangedSubview(bodyView)
            bodyView.snp.makeConstraints {
                $0.height.equalTo(FeedCellContentOnlyBodyView.Layout.height)
            }
        default:
            return
        }
    }
}
