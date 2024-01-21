import UIKit

import Common
import DesignSystem
import Model

final class FaqView: BaseView {
    let backButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image.withTintColor(Colors.systemWhite.color)
        
        button.setImage(image, for: .normal)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.medium.font(size: 16)
        label.textColor = Colors.systemWhite.color
        label.text = Strings.Qna.title
        
        return label
    }()
    
    private let mainTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.systemWhite.color
        label.font = Fonts.bold.font(size: 24)
        label.text = Strings.Faq.title
        
        return label
    }()
    
    let categoryView = FaqCategoryView()
    
    let faqCollectionView = FaqCollectionView()
    
    override func setup() {
        backgroundColor = Colors.gray100.color
        
        addSubViews([
            backButton,
            titleLabel,
            mainTitleLabel,
            categoryView,
            faqCollectionView
        ])
    }
    
    override func bindConstraints() {
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
        }
        
        mainTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(36)
        }
        
        categoryView.snp.makeConstraints {
            $0.top.equalTo(mainTitleLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.leading.lessThanOrEqualToSuperview().offset(44)
            $0.trailing.lessThanOrEqualToSuperview().offset(-44)
            $0.height.equalTo(0)
        }
        
        faqCollectionView.snp.makeConstraints {
            $0.top.equalTo(categoryView.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func updateCategoryViewHeight(categories: [FaqCategoryResponse]) {
        let height = FaqCategoryView.Layout.calculateHeight(categories: categories)
        categoryView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
}
