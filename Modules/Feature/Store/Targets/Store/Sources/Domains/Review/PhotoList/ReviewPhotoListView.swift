import UIKit
import Combine

import Common
import DesignSystem
import Model

final class ReviewPhotoListView: BaseView {
    let removeImage = PassthroughSubject<Int, Never>()
    let didTapUploadPhoto = PassthroughSubject<Void, Never>()
    
    weak var containerViewController: UIViewController?
    
    struct Config {
        let size: CGSize
        let canEdit: Bool
        var maxCount: Int = 10
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    )
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private let photoAddButtonView = ReviewPhotoAddButtonView()
    
    private var imageList: [ImageResponse] = []
    
    private let config: Config

    init(config: Config) {
        self.config = config
        
        super.init(frame: .zero)
        
        bindEvent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: bounds.width, height: config.size.height)
    }
    
    override func setup() {
        backgroundColor = .clear
        
        addSubViews([
            collectionView,
            photoAddButtonView
        ])
        
        collectionView.register([
            ReviewPhotoListCell.self
        ])

        collectionView.registerSectionHeader([
            ReviewPhotoListHeaderView.self
        ])
        
        photoAddButtonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        photoAddButtonView.isHidden = true
    }
    
    override func bindConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bindEvent() {
        photoAddButtonView.controlPublisher(for: .touchUpInside)
            .mapVoid
            .subscribe(didTapUploadPhoto)
            .store(in: &cancellables)
    }
    
    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = WidthAdaptiveFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = config.canEdit ? 4 : 8
        layout.minimumLineSpacing = config.canEdit ? 4 : 8
        layout.sectionInset.left = config.canEdit ? 4 : .zero
        return layout
    }
    
    func setImages(_ imageList: [ImageResponse]) {
        self.imageList = imageList
        photoAddButtonView.isHidden = imageList.isNotEmpty || config.canEdit.isNot
        collectionView.reloadData()
    }
    
    private func presentPhotoDetail(selectedIndex: Int) {
        let config = BossStorePhotoViewModel.Config(photos: imageList, selectedIndex: selectedIndex)
        let viewModel = BossStorePhotoViewModel(config: config)
        let viewController = BossStorePhotoViewController(viewModel: viewModel)
        containerViewController?.present(viewController, animated: true)
    }
}

extension ReviewPhotoListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ReviewPhotoListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(imageUrl: imageList[safe: indexPath.item]?.imageUrl, canEdit: config.canEdit)
        cell.removeButton.tapPublisher
            .sink { [weak self] in
                self?.removeImage.send(indexPath.item)
            }
            .store(in: &cell.cancellables)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: ReviewPhotoListHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
        headerView.bind(totalCount: imageList.count, maxCount: config.maxCount)
        headerView.didTapEvent
            .subscribe(didTapUploadPhoto)
            .store(in: &headerView.cancellables)
        return headerView
    }
}

extension ReviewPhotoListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentPhotoDetail(selectedIndex: indexPath.item)
    }
}

extension ReviewPhotoListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return config.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard config.canEdit else { return .zero }
        
        return imageList.isEmpty ? .zero : config.size
    }
}

// MARK: - EmptyView
final class ReviewPhotoAddButtonView: UIControl {
    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = Colors.systemWhite.color
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Colors.gray20.color.cgColor
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Fonts.semiBold.font(size: 14)
        titleLabel.textColor = Colors.gray70.color
        titleLabel.text = Strings.ReviewBottomSheet.attachPhoto
        return titleLabel
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Icons.imageAdd.image
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubViews([containerView])
        containerView.addSubViews([stackView])
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
