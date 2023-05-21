import UIKit

final class RegisterPhotoView: BaseView {
    private let navigationView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
  
    let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_close"), for: .normal)
    }
  
    private let titleLabel = UILabel().then {
        $0.font = .semiBold(size: 16)
        $0.textColor = .black
        $0.text = "register_photo_title".localized
    }
  
    let photoCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    ).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = RegisterPhotoCollectionViewCell.itemSize
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        $0.allowsMultipleSelection = true
        $0.register(
            RegisterPhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: RegisterPhotoCollectionViewCell.registerId
        )
    }
    
    let registerButton = RegisterButton()
    
    override func setup() {
        self.photoCollectionView.delegate = self
        self.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        self.addSubViews([
            self.navigationView,
            self.closeButton,
            self.titleLabel,
            self.photoCollectionView,
            self.registerButton
        ])
    }
    
    override func bindConstraints() {
        self.navigationView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(60)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalTo(self.titleLabel)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.navigationView).offset(-21)
        }
        
        self.photoCollectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.navigationView.snp.bottom)
        }
        
        self.registerButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-34)
        }
    }
    
    func deselectCollectionItem(index: Int) {
        self.photoCollectionView.deselectItem(at: IndexPath(row: index, section: 0), animated: true)
    }
  
    func hideRegisterButton() {
        let originalButtonTransform = self.registerButton.transform
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
            self?.registerButton.transform = originalButtonTransform.translatedBy(x: 0.0, y: 90)
            self?.registerButton.alpha = 0
        })
    }
  
    func showRegisterButton() {
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
            self?.registerButton.transform = .identity
            self?.registerButton.alpha = 1
        })
    }
}

extension RegisterPhotoView: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hideRegisterButton()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.showRegisterButton()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.showRegisterButton()
    }
}
