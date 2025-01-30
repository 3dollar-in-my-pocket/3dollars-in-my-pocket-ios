import UIKit
import Combine

import Common
import DesignSystem

final class ReviewPhotoListView: BaseView {
    let removeImage = PassthroughSubject<Int, Never>()
    let didTapUploadPhoto = PassthroughSubject<Void, Never>()
    
    struct Config {
        let size: CGSize
        let canEdit: Bool
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: generateLayout()
    ).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.delegate = self
        $0.dataSource = self
    }
    
    private let photoAddButtonView = ReviewPhotoAddButtonView()
    
    private var imageUrls: [String] = []
    
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
            ReviewPhotoListHeaderView.self,
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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset.left = config.canEdit ? 8 : .zero
        return layout
    }
    
    func setImages(_ urls: [String]) {
        imageUrls = urls
        photoAddButtonView.isHidden = self.imageUrls.isNotEmpty || config.canEdit.isNot
        collectionView.reloadData()
    }
}

extension ReviewPhotoListView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ReviewPhotoListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        cell.bind(imageUrl: imageUrls[safe: indexPath.item], canEdit: config.canEdit)
        cell.removeButton.tapPublisher
            .sink { [weak self] in
                self?.removeImage.send(indexPath.item)
            }
            .store(in: &cell.cancellables)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView: ReviewPhotoListHeaderView = collectionView.dequeueReusableSupplementaryView(ofkind: UICollectionView.elementKindSectionHeader, indexPath: indexPath)
        headerView.bind(totalCount: imageUrls.count)
        headerView.didTapEvent
            .subscribe(didTapUploadPhoto)
            .store(in: &headerView.cancellables)
        return headerView
    }
}

extension ReviewPhotoListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension ReviewPhotoListView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return config.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard config.canEdit else { return .zero }
        
        return imageUrls.isEmpty ? .zero : config.size
    }
}

// MARK: - EmptyView
final class ReviewPhotoAddButtonView: UIControl {
    private let containerView = UIView().then {
        $0.backgroundColor = Colors.gray10.color
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 4
    }
    
    private let titleLabel = UILabel().then {
        $0.font = Fonts.regular.font(size: 14)
        $0.textColor = Colors.gray60.color
        $0.text = "사진 추가하기"
    }
    
    private let imageView = UIImageView().then {
        $0.image = Icons.camera.image.resizeImage(scaledTo: 21).withTintColor(Colors.gray60.color)
    }
    
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
            $0.leading.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(53)
        }
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
