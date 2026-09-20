import UIKit

import SnapKit

import Model
import DesignSystem
import Common
import Network

final class MyPageOverviewCell: BaseCollectionViewCell {
    
    enum Layout {
        static let height: CGFloat = 240
    }
    
    private let bgCloud: UIImageView = {
        let bgCloud = UIImageView()
        bgCloud.image = MyPageAsset.bgCloud.image
        return bgCloud
    }()
    
    private let medalImageButton = UIButton()
    
    private let medalLabel: PaddingLabel = {
        let medalLabel = PaddingLabel(topInset: 3, bottomInset: 3, leftInset: 4, rightInset: 4)
        medalLabel.font = Fonts.medium.font(size: 10)
        medalLabel.backgroundColor = Colors.gray80.color
        medalLabel.textColor = Colors.mainPink.color
        medalLabel.layer.cornerRadius = 4
        medalLabel.clipsToBounds = true
        return medalLabel
    }()
    
    private let nicknameLabel: UILabel = {
        let nicknameLabel = UILabel()
        nicknameLabel.font = Fonts.bold.font(size: 30)
        nicknameLabel.textAlignment = .center
        nicknameLabel.textColor = .white
        return nicknameLabel
    }()
    
    private let stackView = UIStackView()
    private let storeCountButton = MyPageOverviewCountButton(type: .store)
    private let reviewCountButton = MyPageOverviewCountButton(type: .review)
    private let medalCountButton = MyPageOverviewCountButton(type: .title)
    
    override func setup() {
        super.setup()
        
        contentView.addSubViews([
            bgCloud,
            medalImageButton,
            medalLabel,
            nicknameLabel,
            stackView
        ])
    }
    
    override func bindConstraints() {
        super.bindConstraints()
        
        bgCloud.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        medalImageButton.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(28)
            $0.size.equalTo(60)
        }
        
        medalLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.medalImageButton.snp.bottom).offset(12)
        }
        
        nicknameLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.medalLabel.snp.bottom).offset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        stackView.addArrangedSubview(storeCountButton)
        stackView.addArrangedSubview(lineView())
        stackView.addArrangedSubview(reviewCountButton)
        stackView.addArrangedSubview(lineView())
        stackView.addArrangedSubview(medalCountButton)
        
        storeCountButton.snp.makeConstraints { 
            $0.size.equalTo(MyPageOverviewCountButton.size)
        }
        reviewCountButton.snp.makeConstraints {
            $0.size.equalTo(MyPageOverviewCountButton.size)
        }
        medalCountButton.snp.makeConstraints { 
            $0.size.equalTo(MyPageOverviewCountButton.size)
        }
    }
    
    private func lineView() -> UIView {
        let view = UIView()
        view.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.height.equalTo(32)
        }
        view.backgroundColor = Colors.gray80.color
        return view
    }
    
    func bind(viewModel: MyPageOverviewCellViewModel) {
        bind(user: viewModel.output.item)
        
        medalImageButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .merge(with: medalCountButton.controlPublisher(for: .touchUpInside).mapVoid)
            .subscribe(viewModel.input.didTapMedalImageButton)
            .store(in: &cancellables)
        
        storeCountButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapStoreCountButton)
            .store(in: &cancellables)
        
        reviewCountButton
            .controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapReviewButton)
            .store(in: &cancellables)
    }
    
    private func bind(user: UserDetailResponse) {
        self.nicknameLabel.text = user.name
        self.medalImageButton.setImage(urlString: user.representativeMedal.iconUrl, state: .normal)
        self.medalLabel.text = user.representativeMedal.name
        self.storeCountButton.bind(count: user.activities?.createStoreCount ?? 0)
        self.reviewCountButton.bind(count: user.activities?.writeReviewCount ?? 0)
        self.medalCountButton.bind(count: user.ownedMedals.count)
    }
}
