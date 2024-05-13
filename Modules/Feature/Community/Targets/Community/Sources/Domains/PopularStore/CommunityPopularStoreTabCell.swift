import UIKit

import Common
import DesignSystem
import Then
import Model

final class CommunityPopularStoreTabCell: BaseCollectionViewCell {

    enum Layout {
        static let size = CGSize(width: UIScreen.main.bounds.width, height: 156)
        static let itemSpacing: CGFloat = 9
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 24)
        $0.textColor = Colors.systemBlack.color
        $0.text = Strings.CommunityPopularStore.Tab.title
    }

    private let districtButton = UIButton().then {
        $0.titleLabel?.font = Fonts.bold.font(size: 16)
        $0.imageEdgeInsets.left = 2
        $0.semanticContentAttribute = .forceRightToLeft
        $0.contentEdgeInsets = .init(top: 6, left: 8, bottom: 6, right: 8)
        $0.setTitleColor(Colors.gray80.color, for: .normal)
        $0.setImage(Icons.arrowRight.image
            .resizeImage(scaledTo: 16)
            .withTintColor(Colors.gray60.color), for: .normal)
    }

    private let tabView = CommunityTabView(titles: CommunityPopularStoreTab.allCases.map { $0.title })
    private let lineView: UIView = UIView().then {
        $0.backgroundColor = Colors.gray20.color
    }

    private var viewModel: CommunityPopularStoreTabCellViewModel?

    override func setup() {
        super.setup()

        backgroundColor = Colors.systemWhite.color

        contentView.addSubViews([
            titleLabel,
            districtButton,
            lineView,
            tabView
        ])
    }

    override func bindConstraints() {
        super.bindConstraints()

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(20)
        }

        districtButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }

        tabView.snp.makeConstraints {
            $0.top.equalTo(districtButton.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tabView)
            $0.height.equalTo(1)
        }
    }

    func bind(viewModel: CommunityPopularStoreTabCellViewModel) {
        self.viewModel = viewModel

        // Input
        tabView.didTap
            .subscribe(viewModel.input.didSelectTab)
            .store(in: &cancellables)

        districtButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapDistrictButton)
            .store(in: &cancellables)

        // Output
        viewModel.output.district
            .withUnretained(self)
            .main
            .sink { owner, district in
                owner.districtButton.setTitle("📍 \(district)", for: .normal)
            }
            .store(in: &cancellables)

        viewModel.output.currentTab
            .removeDuplicates()
            .withUnretained(self)
            .main
            .sink { owner, tab in
                let index = owner.viewModel?.output.tabList.firstIndex(where: { $0 == tab })
                owner.tabView.updateSelect(index ?? 0)
            }
            .store(in: &cancellables)
        
    }
}
