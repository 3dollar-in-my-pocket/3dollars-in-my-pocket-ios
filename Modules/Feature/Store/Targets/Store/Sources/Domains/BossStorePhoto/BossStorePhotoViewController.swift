import UIKit

import Common
import DesignSystem
import Log

import CombineCocoa

final class BossStorePhotoViewController: BaseViewController {
    private let viewModel: BossStorePhotoViewModel
    private var isFirstLoad = true
    
    override var screenName: ScreenName {
        viewModel.output.screenName
    }
    
    init(viewModel: BossStorePhotoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let image =  DesignSystemAsset.Icons.close.image.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.tintColor = Colors.systemWhite.color
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    private let leftButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowLeft.image
            .resizeImage(scaledTo: 20)
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Colors.mainPink.color
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = Colors.gray95.color
        return button
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular.font(size: 14)
        label.textColor = Colors.systemWhite.color
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        let image = Icons.arrowRight.image
            .resizeImage(scaledTo: 20)
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = Colors.mainPink.color
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = Colors.gray95.color
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttribute()
        setupUI()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstLoad {
            isFirstLoad = false
            viewModel.input.firstLoad.send(())
        }
    }
    
    private func setupUI() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        view.addSubview(leftButton)
        leftButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(44)
        }
        
        view.addSubview(rightButton)
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.size.equalTo(44)
        }
        
        view.addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(leftButton)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(leftButton.snp.top).offset(-16)
        }
    }
    
    private func setupAttribute() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register([
            BaseCollectionViewCell.self,
            BossStorePhotoItemCell.self
        ])
        
        view.backgroundColor = Colors.gray100.color
    }
    
    private func bind() {
        // Input
        closeButton.tapPublisher
            .main
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewController, _) in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
        
        leftButton.tapPublisher
            .subscribe(viewModel.input.didTapLeft)
            .store(in: &cancellables)
        
        rightButton.tapPublisher
            .subscribe(viewModel.input.didTapRight)
            .store(in: &cancellables)
        
        // Output
        viewModel.output.scrollToIndex
            .first()
            .main
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewController, index: Int) in
                let targetIndex = IndexPath(item: index, section: 0)
                owner.collectionView.scrollToItemIfAvailable(at: targetIndex, at: .centeredHorizontally, animated: false)
            }
            .store(in: &cancellables)
        
        viewModel.output.scrollToIndex
            .dropFirst()
            .main
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewController, index: Int) in
                let targetIndex = IndexPath(item: index, section: 0)
                owner.collectionView.scrollToItemIfAvailable(at: targetIndex, at: .centeredHorizontally, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.currentIndex
            .main
            .withUnretained(self)
            .sink { (owner: BossStorePhotoViewController, index: Int) in
                owner.setcurrentIndex(index)
            }
            .store(in: &cancellables)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = .zero
        layout.minimumLineSpacing = .zero
        return layout
    }
    
    private func setcurrentIndex(_ index: Int) {
        countLabel.text = "\(index + 1)/\(viewModel.output.photos.count)"
    }
}

extension BossStorePhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.output.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let photo = viewModel.output.photos[safe: indexPath.item] else { return BaseCollectionViewCell() }
        let cell: BossStorePhotoItemCell = collectionView.dequeueReuseableCell(indexPath: indexPath)
        
        cell.bind(imageResponse: photo)
        return cell
    }
}

extension BossStorePhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / collectionView.frame.size.width)
        
        viewModel.input.didScroll.send(index)
    }
}
