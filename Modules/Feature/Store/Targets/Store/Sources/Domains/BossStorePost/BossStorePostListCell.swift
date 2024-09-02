import UIKit

import Common
import DesignSystem
import Model

final class BossStorePostListCell: BaseCollectionViewCell {
    enum Layout {
        static func height(viewModel: BossStorePostListCellViewModel, width: CGFloat) -> CGFloat {
            var totalHeight: CGFloat = 0
            
            let headerHeight: CGFloat = 72
            totalHeight += headerHeight
            
            if viewModel.output.data.sections.isNotEmpty {
                totalHeight += BossStorePostImageCell.Layout.height
                totalHeight += 12 // 이미지 하단 패딩
            }
            
            let contentHeight = viewModel.output.data.body.boundingRect(
                with: CGSize(
                    width: width - sectionInset.left - sectionInset.right,
                    height: CGFloat.greatestFiniteMagnitude
                ),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [
                    .font: Fonts.regular.font(size: 14)
                ],
                context: nil
            ).height
            
            totalHeight += contentHeight
            totalHeight += 12 // 컨텐츠 하단 패딩
            
            let likeButtonHeight: CGFloat = 16
            totalHeight += likeButtonHeight
            totalHeight += 16 // 좋아요 버튼 하단 패딩
            
            let lineHeight: CGFloat = 1
            totalHeight += lineHeight
            
            return totalHeight
        }
        
        static let sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        static let contentTextFont = Fonts.regular.font(size: 14)
        static let contentTextColor = Colors.gray95.color
    }
    
    private let categoryImageView = UIImageView()
    
    private let storeNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 14)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let updatedAtLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 12)
        label.textColor = Colors.gray40.color
        return label
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.font = Layout.contentTextFont
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.medium.font(size: 10)
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 2)
        return button
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.gray10.color
        return view
    }()
    
    private weak var viewModel: BossStorePostListCellViewModel?
    
    override func setup() {
        setupUI()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register([
            BaseCollectionViewCell.self,
            BossStorePostImageCell.self
        ])
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        contentView.addSubview(categoryImageView)
        contentView.addSubview(storeNameLabel)
        contentView.addSubview(updatedAtLabel)
        contentView.addSubview(contentStackView)
        contentView.addSubview(lineView)
        
        contentStackView.addArrangedSubview(collectionView)
        contentStackView.addArrangedSubview(textView)
        contentStackView.addArrangedSubview(likeButton)
        
        categoryImageView.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.leading.equalToSuperview().inset(16)
        }
        
        storeNameLabel.snp.makeConstraints {
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(8)
            $0.top.equalToSuperview().inset(17)
            $0.height.equalTo(20)
        }
        
        updatedAtLabel.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom)
            $0.leading.equalTo(storeNameLabel)
            $0.height.equalTo(18)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(categoryImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints {
            $0.height.equalTo(BossStorePostImageCell.Layout.height)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        likeButton.snp.makeConstraints {
            $0.height.equalTo(16)
        }
        
        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        return layout
    }
    
    func bind(_ viewModel: BossStorePostListCellViewModel) {
        if let category = viewModel.output.data.store.categories.first {
            categoryImageView.setImage(urlString: category.imageUrl)
        }
        storeNameLabel.text = viewModel.output.data.store.storeName
        updatedAtLabel.text = viewModel.output.data.updatedAt.toDate()?.toRelativeString()
        collectionView.isHidden = viewModel.output.data.sections.isEmpty
        
        textView.attributedText = NSAttributedString(
            string: viewModel.output.data.body,
            attributes: [
                .font: Layout.contentTextFont,
                .foregroundColor: Layout.contentTextColor
            ]
        )
        
        if let sticker = viewModel.output.data.stickers.first {
            setSticker(sticker)
        }
        
        if self.viewModel != viewModel {
            collectionView.reloadData()
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.setContentOffset(viewModel.output.scrollOffset.value, animated: false)
            }
        }
        
        self.viewModel = viewModel
        
        likeButton.tapPublisher
            .handleEvents(receiveOutput: {
                FeedbackGenerator.shared.generate(.impact)
            })
            .subscribe(viewModel.input.didTapLike)
            .store(in: &cancellables)
    }
    
    private func setSticker(_ sticker: StickerResponse) {
        if sticker.reactedByMe {
            let image = Icons.heartFill.image
                .resizeImage(scaledTo: 16)
                .withRenderingMode(.alwaysTemplate)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = Colors.mainRed.color
            likeButton.setTitleColor(Colors.mainRed.color, for: .normal)
        } else {
            let image = Icons.heartLine.image
                .resizeImage(scaledTo: 16)
                .withRenderingMode(.alwaysTemplate)
            likeButton.setImage(image, for: .normal)
            likeButton.tintColor = Colors.gray60.color
            likeButton.setTitleColor(Colors.gray60.color, for: .normal)
        }
        likeButton.setTitle("좋아요 \(sticker.count)", for: .normal)
    }
}

extension BossStorePostListCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.output.data.sections.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageUrl = viewModel?.output.data.sections[safe: indexPath.item]?.url else { return BaseCollectionViewCell() }
        
        let cell: BossStorePostImageCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(imageUrl)
        return cell
    }
}

extension BossStorePostListCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapPhoto.send(indexPath.item)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel?.input.didScroll.send(scrollView.contentOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let ratio = viewModel?.output.data.sections[safe: indexPath.item]?.ratio else {
            return CGSize(width: BossStorePostImageCell.Layout.height, height: BossStorePostImageCell.Layout.height)
        }
        
        let width = BossStorePostImageCell.Layout.height * ratio
        let height = BossStorePostImageCell.Layout.height
        
        return CGSize(width: width, height: height)
    }
}

// MARK: - Image Cell
private final class BossStorePostImageCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 208
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = Colors.gray70.color
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.layer.borderColor = Colors.gray20.color.cgColor
        $0.layer.borderWidth = 0.5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.clear()
    }
    
    override func setup() {
        contentView.addSubview(imageView)
    }
    
    override func bindConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind(_ imageUrl: String) {
        imageView.setImage(urlString: imageUrl)
    }
}

extension BossStorePostImageCell: Displayable {
    func didEndDisplaying() {
        imageView.clear()
    }
}
