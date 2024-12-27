import UIKit
import Common
import DesignSystem
import Model

final class BossStoreInfoCell: BaseCollectionViewCell {
    enum Layout {
        static func calculateHeight(width: CGFloat, info: BossStoreInfo) -> CGFloat {
            let introducationHeight = calculateIntroductionHeight(width: width, introduction: info.introduction) + calculateAccountHeight(account: info.accountInfos.first)
            
            return introducationHeight + 356
        }
        
        static func calculateIntroductionHeight(width: CGFloat, introduction: String?) -> CGFloat {
            guard let introduction else { return .zero }

            let contentHeight = introduction.boundingRect(
                with: CGSize(
                    width: width - 24,
                    height: CGFloat.greatestFiniteMagnitude
                ),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [
                    .font: Fonts.bold.font(size: 12)
                ],
                context: nil
            ).height
            
            return contentHeight
        }
        
        static func calculateAccountHeight(account: StoreAccountNumber?) -> CGFloat {
            return account.isNil ? 0 : BossStoreAccountView.Layout.height
        }
    }

    private let titleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 16)
        $0.textColor = Colors.gray100.color
        $0.text = Strings.BossStoreDetail.Info.title
    }

    private let updatedAtLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
    }

    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray0.color
        $0.layer.cornerRadius = 20
    }

    private let snsTitleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = Strings.BossStoreDetail.Info.sns
    }

    let snsButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.titleLabel?.textAlignment = .right
    }
    
    private let contactLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 12)
        label.textColor = Colors.gray60.color
        label.text = Strings.BossStoreDetail.Info.contact
        return label
    }()
    
    let contactButton = UIButton().then {
        $0.titleLabel?.font = Fonts.medium.font(size: 12)
        $0.setTitleColor(Colors.mainPink.color, for: .normal)
        $0.titleLabel?.textAlignment = .right
    }

    private let introductionTitleLabel = UILabel().then {
        $0.font = Fonts.bold.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.text = Strings.BossStoreDetail.Info.introduction
    }

    private let introductionValueLabel = UILabel().then {
        $0.font = Fonts.medium.font(size: 12)
        $0.textColor = Colors.gray60.color
        $0.numberOfLines = 0
        $0.textAlignment = .left
    }
    
    private lazy var photoCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let accountView = BossStoreAccountView()
    
    private var viewModel: BossStoreInfoCellViewModel?

    override func setup() {
        backgroundColor = .clear
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register([BossStoreInfoPhotoItemCell.self])

        addSubViews([
            titleLabel,
            updatedAtLabel,
            containerView,
            photoCollectionView,
            accountView
        ])

        containerView.addSubViews([
            snsTitleLabel,
            snsButton,
            contactLabel,
            contactButton,
            introductionTitleLabel,
            introductionValueLabel
        ])
    }

    override func bindConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }

        updatedAtLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview()
        }

        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(updatedAtLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(BossStoreInfoPhotoItemCell.Layout.size.height)
        }

        containerView.snp.makeConstraints {
            $0.top.equalTo(photoCollectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(introductionValueLabel).offset(16)
        }

        snsTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.width.equalTo(104)
        }

        snsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(snsTitleLabel)
        }
        
        contactLabel.snp.makeConstraints {
            $0.leading.equalTo(snsTitleLabel)
            $0.top.equalTo(snsTitleLabel.snp.bottom).offset(8)
        }
        
        contactButton.snp.makeConstraints {
            $0.trailing.equalTo(snsButton)
            $0.centerY.equalTo(contactLabel)
        }

        introductionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contactLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
        }

        introductionValueLabel.snp.makeConstraints {
            $0.top.equalTo(introductionTitleLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        accountView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.bottom).offset(12)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }

    func bind(_ viewModel: BossStoreInfoCellViewModel) {
        self.viewModel = viewModel
        
        // Bind Input
        snsButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapSnsButton)
            .store(in: &cancellables)
        
        accountView.copyButton.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(viewModel.input.didTapCopyAccountNumber)
            .store(in: &cancellables)
        
        // Bind output
        setInfo(viewModel.output.info)
        
        viewModel.output.toast
            .main
            .sink { message in
                ToastManager.shared.show(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func setInfo(_ info: BossStoreInfo) {
        if let snsUrl = info.snsUrl {
            snsButton.isHidden = snsUrl.isEmpty
            snsButton.setTitle(snsUrl, for: .normal)
        } else {
            snsButton.isHidden = true
        }
        
        if let contactsNumber = info.contactsNumbers.first {
            contactButton.isHidden = contactsNumber.number.isEmpty
            contactButton.setTitle(contactsNumber.number, for: .normal)
        } else {
            contactButton.isHidden = true
        }
        
        introductionValueLabel.text = info.introduction
        
        photoCollectionView.reloadData()

        updatedAtLabel.text = DateUtils.toString(dateString: info.updatedAt, format: "yyyy.MM.dd " + Strings.BossStoreDetail.Info.update)
        
        if let accountInfo = info.accountInfos.first {
            accountView.isHidden = false
            accountView.bind(account: accountInfo)
        } else {
            accountView.isHidden = true
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = BossStoreInfoPhotoItemCell.Layout.size
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        return layout
    }
}

extension BossStoreInfoCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.info.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel,
              let photo = viewModel.output.info.images[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: BossStoreInfoPhotoItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(imageUrl: photo.imageUrl)
        return cell
    }
}

extension BossStoreInfoCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapPhoto.send(indexPath.item)
    }
}
