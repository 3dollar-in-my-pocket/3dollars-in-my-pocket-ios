import UIKit

import Common
import Model
import CombineCocoa

final class StoreDetailImageCell: BaseCollectionViewCell {
    enum Layout {
        static let height: CGFloat = 146
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.bold.font(size: 16)
        label.textColor = Colors.gray100.color
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = Fonts.bold.font(size: 12)
        button.setTitleColor(Colors.mainPink.color, for: .normal)
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var dataSource: [SDImage] = []
    private var viewModel: StoreDetailImageCellViewModel?
    
    override func setup() {
        contentView.addSubViews([
            titleLabel,
            rightButton,
            collectionView
        ])
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(rightButton.snp.leading).offset(-16)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(titleLabel)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-32)
            $0.height.equalTo(78)
        }
    }
    
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = StoreDetailImageItemCell.Layout.size
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func bind(viewModel: StoreDetailImageCellViewModel) {
        bindHeader(header: viewModel.output.header)
        
        rightButton.tapPublisher
            .throttleClick()
            .subscribe(viewModel.input.didTapHeaderButton)
            .store(in: &cancellables)
        
        viewModel.output.images
            .main
            .sink { [weak self] images in
                self?.dataSource = images
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        self.viewModel = viewModel
    }
    
    private func bindHeader(header: HeaderSectionResponse) {
        titleLabel.setSDText(header.title)
        if let rightSDButton = header.rightButton {
            rightButton.setSDButton(rightSDButton)
        }
    }
}

extension StoreDetailImageCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let image = dataSource[safe: indexPath.item] else {
            return UICollectionViewCell()
        }
        
        let cell: StoreDetailImageItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        
        cell.bind(sdImage: image)
        
        if indexPath.item == dataSource.count - 1,
           let more = viewModel?.output.more {
            cell.bind(more: more)
        }
        
        return cell
    }
}

extension StoreDetailImageCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.input.didTapImage.send(indexPath.item)
    }
}
