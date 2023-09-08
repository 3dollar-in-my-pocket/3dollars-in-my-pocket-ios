import UIKit

import Common
import DesignSystem

final class StoreDetailOverviewTitleView: BaseView {
    enum Layout {
        static let height: CGFloat = 78
    }
    
    private let categoryImage = UIImageView()
    
    private let repoterLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray50.color
        $0.text = "맛돌이님 제보"
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.semiBold.font(size: 20)
        $0.textColor = Colors.gray100.color
        $0.text = "강남역 0번 출구 앞 붕어빵"
    }
    
    private let newBadge = UIImageView(image: Assets.iconNewBadge.image)
    
    private let visitCountLabel = PaddingLabel(
        topInset: 3,
        bottomInset: 3,
        leftInset: 8,
        rightInset: 8
    ).then {
        $0.backgroundColor = Colors.pink100.color
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
        $0.textColor = Colors.mainPink.color
        $0.font = Fonts.medium.font(size: 12)
        $0.text = "최근 한달 9명이 방문 성공"
    }
    
    private let infoVIew = StoreDetailOverviewInfoCellView()
    
    override func setup() {
        addSubViews([
            categoryImage,
            repoterLabel,
            titleLabel,
            newBadge,
            visitCountLabel,
            infoVIew
        ])
    }
    
    override func bindConstraints() {
        categoryImage.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.top.equalToSuperview()
            $0.size.equalTo(48)
        }
        
        repoterLabel.snp.makeConstraints {
            $0.left.equalTo(categoryImage.snp.right).offset(8)
            $0.top.equalToSuperview()
            $0.right.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(repoterLabel)
            $0.top.equalTo(repoterLabel.snp.bottom).offset(4)
            $0.right.lessThanOrEqualToSuperview().offset(-18)
        }
        
        newBadge.snp.makeConstraints {
            $0.left.equalTo(titleLabel.snp.right).offset(4)
            $0.size.equalTo(14)
            $0.top.equalTo(titleLabel).offset(4)
        }
        
        visitCountLabel.snp.makeConstraints {
            $0.left.equalTo(repoterLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.height.equalTo(24)
        }
        
        infoVIew.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalTo(visitCountLabel)
        }
    }
}
