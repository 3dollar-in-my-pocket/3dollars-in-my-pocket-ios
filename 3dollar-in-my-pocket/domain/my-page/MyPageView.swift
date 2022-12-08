import UIKit

import RxSwift
import RxCocoa

final class MyPageView: BaseView {
    let refreshControl = UIRefreshControl().then {
        $0.tintColor = .white
    }
    
    private let navigationBackgroundView = UIView().then {
        $0.backgroundColor = R.color.gray95()
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .semiBold(size: 16)
        $0.text = R.string.localization.my_page_title()
    }
    
    let settingButton = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_setting"), for: .normal)
    }
    
    let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewLayout()
    ).then {
        $0.register(
            MyPageOverviewCollectionViewCell.self,
            forCellWithReuseIdentifier: MyPageOverviewCollectionViewCell.registerId
        )
        $0.register(
            MyPageVisitHistoryCollectionViewCell.self,
            forCellWithReuseIdentifier: MyPageVisitHistoryCollectionViewCell.registerId
        )
        $0.register(
            MyPageBookmarkCollectionViewCell.self,
            forCellWithReuseIdentifier: MyPageBookmarkCollectionViewCell.registerId
        )
        $0.register(
            MyPageSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MyPageSectionHeaderView.registerId
        )
        $0.backgroundColor = R.color.gray100()
        $0.contentInset = .init(top: 0, left: 0, bottom: 24, right: 0)
    }
    
    override func setup() {
        self.backgroundColor = R.color.gray100()
        self.collectionView.collectionViewLayout = self.generateCompositionalLayout()
        self.collectionView.refreshControl = self.refreshControl
        self.addSubViews([
            self.navigationBackgroundView,
            self.titleLabel,
            self.settingButton,
            self.collectionView
        ])
        
        self.collectionView.rx.contentOffset
            .map { $0.y >= 0 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isPlusOffset in
                self?.collectionView.backgroundColor = isPlusOffset
                ? R.color.gray100()
                : R.color.gray95()
            })
            .disposed(by: self.disposeBag)
    }
    
    override func bindConstraints() {
        self.navigationBackgroundView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.titleLabel).offset(23)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide).offset(23)
        }
        
        self.settingButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(15)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(24)
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(self.navigationBackgroundView.snp.bottom)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    private func generateCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let compositionLayout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch sectionIndex {
            case 0:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyPageOverviewCollectionViewCell.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(MyPageOverviewCollectionViewCell.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            case 1:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .absolute(MyPageVisitHistoryCollectionViewCell.size.width),
                    heightDimension: .absolute(MyPageVisitHistoryCollectionViewCell.size.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .absolute(MyPageVisitHistoryCollectionViewCell.size.width),
                    heightDimension: .absolute(MyPageVisitHistoryCollectionViewCell.size.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyPageSectionHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )]
                section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
                section.decorationItems = [
                    .background(elementKind: MyPageDecorationView.registerId)
                ]
                
                return section
                
            case 2:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .absolute(MyPageBookmarkCollectionViewCell.size.width),
                    heightDimension: .absolute(MyPageBookmarkCollectionViewCell.size.height)
                ))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(
                    widthDimension: .absolute(MyPageBookmarkCollectionViewCell.size.width),
                    heightDimension: .absolute(MyPageBookmarkCollectionViewCell.size.height)
                ), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [.init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(MyPageSectionHeaderView.height)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )]
                section.contentInsets = .init(top: 0, leading: 24, bottom: 0, trailing: 24)
                section.decorationItems = [
                    .background(elementKind: MyPageDecorationView.registerId)
                ]
                
                return section
                
            default:
                return nil
            }
        }
        
        compositionLayout.register(
            MyPageDecorationView.self,
            forDecorationViewOfKind: MyPageDecorationView.registerId
        )
        return compositionLayout
    }
}
