import UIKit

class ImageDetailView: BaseView {
    
    let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    let closeBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_close"), for: .normal)
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
        setupNavigationBarShadow()
        backgroundColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.8)
        addSubViews(navigationBar, closeBtn, mainImage, bottomBackground, collectionView)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = navigationBar.frame
        rectShape.position = navigationBar.center
        rectShape.path = UIBezierPath(roundedRect: navigationBar.frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 16, height: 16)).cgPath

        navigationBar.layer.backgroundColor = UIColor.white.cgColor
        navigationBar.layer.mask = rectShape
    }
    
    private func setupNavigationBarShadow() {
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: frame.width, height: 98), cornerRadius: 16).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.08
        shadowLayer.shadowRadius = 20
        
        navigationBar.layer.insertSublayer(shadowLayer, at: 0)
    }
}
