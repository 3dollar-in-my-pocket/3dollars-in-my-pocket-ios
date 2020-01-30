import UIKit

class ImageDetailView: BaseView {
    
    let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    let closeBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_close"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.textColor = UIColor.init(r: 51, g: 51, b: 51)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let mainImage = UIImageView().then {
        $0.backgroundColor = .white
    }
    
    let bottomBackground = UIView().then {
        $0.backgroundColor = .white
    }
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    
    override func setup() {
        setupNavigationBar()
        backgroundColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.8)
        addSubViews(navigationBar, closeBtn, titleLabel, mainImage, bottomBackground, collectionView)
        
        bottomBackground.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottomBackground.layer.shadowColor = UIColor.black.cgColor
        bottomBackground.layer.shadowOpacity = 0.04
        
    }
    
    override func bindConstraints() {
        navigationBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(98)
        }
        
        closeBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(48)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(closeBtn.snp.centerY)
        }
        
        mainImage.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(frame.width)
        }
        
        bottomBackground.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(120)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(70)
        }
    }
    
    private func setupNavigationBar() {
        navigationBar.layer.cornerRadius = 16
        navigationBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        navigationBar.layer.shadowOffset = CGSize(width: 8, height: 8)
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOpacity = 0.08
    }
}
