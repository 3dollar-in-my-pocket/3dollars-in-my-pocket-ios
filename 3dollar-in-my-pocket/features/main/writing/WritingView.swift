import UIKit
import GoogleMaps

class WritingView: BaseView {
    
    let bgTap = UITapGestureRecognizer().then {
        $0.cancelsTouchesInView = false
    }
    
    let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_close"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "가게 제보"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textColor = UIColor.init(r: 51, g: 51, b: 51)
    }
    
    let scrollView = UIScrollView().then {
        $0.isUserInteractionEnabled = true
    }
    
    let containerView = UIView().then {
        $0.isUserInteractionEnabled = true
    }
    
    let mapView = GMSMapView()
    
    let marker = UIImageView().then {
        $0.image = UIImage.init(named: "ic_marker")
    }
    
    let myLocationBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_location"), for: .normal)
    }
    
    let categoryLabel = UILabel().then {
        $0.text = "카테고리"
        $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
    }
    
    let bungeoppangBtn = UIButton().then {
        $0.setTitle("붕어빵", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setBackgroundColor(UIColor.init(r: 28, g: 28, b: 28), for: .selected)
        $0.setBackgroundColor(UIColor.init(r: 240, g: 240, b: 240), for: .normal)
        $0.setTitleColor(UIColor.init(r: 243, g: 162, b: 169), for: .selected)
        $0.setTitleColor(UIColor.init(r: 194, g: 194, b: 194), for: .normal)
    }
    
    let takoyakiBtn = UIButton().then {
        $0.setTitle("문어빵", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setBackgroundColor(UIColor.init(r: 28, g: 28, b: 28), for: .selected)
        $0.setBackgroundColor(UIColor.init(r: 240, g: 240, b: 240), for: .normal)
        $0.setTitleColor(UIColor.init(r: 243, g: 162, b: 169), for: .selected)
        $0.setTitleColor(UIColor.init(r: 194, g: 194, b: 194), for: .normal)
    }
    
    let gyeranppangBtn = UIButton().then {
        $0.setTitle("계란빵", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setBackgroundColor(UIColor.init(r: 28, g: 28, b: 28), for: .selected)
        $0.setBackgroundColor(UIColor.init(r: 240, g: 240, b: 240), for: .normal)
        $0.setTitleColor(UIColor.init(r: 243, g: 162, b: 169), for: .selected)
        $0.setTitleColor(UIColor.init(r: 194, g: 194, b: 194), for: .normal)
    }
    
    let hotteokBtn = UIButton().then {
        $0.setTitle("호떡", for: .normal)
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.setBackgroundColor(UIColor.init(r: 28, g: 28, b: 28), for: .selected)
        $0.setBackgroundColor(UIColor.init(r: 240, g: 240, b: 240), for: .normal)
        $0.setTitleColor(UIColor.init(r: 243, g: 162, b: 169), for: .selected)
        $0.setTitleColor(UIColor.init(r: 194, g: 194, b: 194), for: .normal)
    }
    
    let nameLabel = UILabel().then {
        $0.text = "가게이름"
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
    }
    
    let nameField = UITextField().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
        $0.layer.borderWidth = 1
        $0.returnKeyType = .done
        $0.placeholder = "ex)강남역 2번출구 앞"
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.textColor = UIColor.init(r: 28, g: 28, b: 28)
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.rightViewMode = .always
    }
    
    let imageLabel = UILabel().then {
        let text = "사진 등록 (선택)"
        let attributedText = NSMutableAttributedString(string: text)
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.init(r: 189, g: 189, b: 189), range: (text as NSString).range(of: "(선택)"))
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
        $0.attributedText = attributedText
    }
    
    let imageCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    let detailLabel = UILabel().then {
        let text = "상세 메뉴 입력 (선택)"
        let attributedText = NSMutableAttributedString(string: text)
        
        attributedText.addAttribute(.foregroundColor, value: UIColor.init(r: 189, g: 189, b: 189), range: (text as NSString).range(of: "(선택)"))
        $0.font = UIFont.init(name: "SpoqaHanSans-Regular", size: 16)
        $0.textColor = UIColor.init(r: 79, g: 79, b: 79)
        $0.attributedText = attributedText
    }
    
    let menuTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
    }
    
    let registerBtnBg = UIView().then {
        $0.layer.cornerRadius = 37
        
        let shadowLayer = CAShapeLayer()
        
        shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 232, height: 72), cornerRadius: 37).cgPath
        shadowLayer.fillColor = UIColor.init(r: 255, g: 255, b: 255, a: 0.6).cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = nil
        shadowLayer.shadowOffset = CGSize(width: 0, height: 1)
        shadowLayer.shadowOpacity = 0.3
        shadowLayer.shadowRadius = 10
        $0.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    let registerBtn = UIButton().then {
        $0.setTitle("현재 위치로 등록하기", for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
        $0.isEnabled = false
        $0.setBackgroundColor(UIColor.init(r: 200, g: 200, b: 200), for: .disabled)
        $0.setBackgroundColor(UIColor.init(r: 238, g: 98, b: 76), for: .normal)
        $0.layer.masksToBounds = true
    }
    
    
    override func setup() {
        backgroundColor = .white
        scrollView.delegate = self
        addGestureRecognizer(bgTap)
        navigationBar.addSubViews(backBtn, titleLabel)
        containerView.addSubViews(mapView, marker, myLocationBtn, categoryLabel, bungeoppangBtn, takoyakiBtn,
                                  gyeranppangBtn, hotteokBtn, nameLabel, nameField, imageLabel,
                                  imageCollection, detailLabel, menuTableView)
        scrollView.addSubview(containerView)
        addSubViews(scrollView, navigationBar, registerBtnBg, registerBtn)
        setupNavigationBar()
    }
    
    override func bindConstraints() {
        navigationBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(99)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-2)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn.snp.centerY)
        }
        
        mapView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(43)
            make.height.equalTo(294)
        }
        
        marker.snp.makeConstraints { (make) in
            make.center.equalTo(mapView.snp.center)
            make.width.equalTo(24)
            make.height.equalTo(32)
        }
        
        myLocationBtn.snp.makeConstraints { (make) in
            make.right.equalTo(mapView.snp.right).offset(-24)
            make.bottom.equalTo(mapView.snp.bottom).offset(-24)
            make.width.height.equalTo(40)
        }
        
        categoryLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(mapView.snp.bottom).offset(49)
        }
        
        bungeoppangBtn.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.top.equalTo(categoryLabel.snp.bottom).offset(8)
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
        
        takoyakiBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(bungeoppangBtn.snp.centerY)
            make.left.equalTo(bungeoppangBtn.snp.right).offset(8)
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
        
        gyeranppangBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(bungeoppangBtn.snp.centerY)
            make.left.equalTo(takoyakiBtn.snp.right).offset(8)
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
        
        hotteokBtn.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.top.equalTo(bungeoppangBtn.snp.bottom).offset(8)
            make.width.equalTo(104)
            make.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.top.equalTo(hotteokBtn.snp.bottom).offset(32)
        }
        
        nameField.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.right.equalTo(gyeranppangBtn.snp.right)
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.height.equalTo(48)
        }
        
        imageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.top.equalTo(nameField.snp.bottom).offset(32)
        }
        
        imageCollection.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageLabel.snp.bottom).offset(16)
            make.height.equalTo(110)
        }
        
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(categoryLabel.snp.left)
            make.top.equalTo(imageCollection.snp.bottom).offset(32)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
            make.width.equalTo(frame.width)
            make.top.equalToSuperview()
            make.bottom.equalTo(menuTableView.snp.bottom)
        }
        
        registerBtnBg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(232)
            make.height.equalTo(72)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        registerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(registerBtnBg.snp.left).offset(8)
            make.right.equalTo(registerBtnBg.snp.right).offset(-8)
            make.top.equalTo(registerBtnBg.snp.top).offset(8)
            make.bottom.equalTo(registerBtnBg.snp.bottom).offset(-8)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshScrollViewHeight()
        registerBtn.layer.cornerRadius = registerBtn.frame.height / 2
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        refreshScrollViewHeight()
    }
    
    private func setupNavigationBar() {
        navigationBar.layer.cornerRadius = 16
        navigationBar.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        navigationBar.layer.shadowOffset = CGSize(width: 8, height: 8)
        navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationBar.layer.shadowOpacity = 0.08
    }
    
    private func refreshScrollViewHeight() {
        menuTableView.snp.remakeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(detailLabel.snp.bottom).offset(8)
            make.height.equalTo(menuTableView.contentSize.height + 85)
        })
    }
    
    func tapCategoryBtn(index: Int) {
        let buttons = [bungeoppangBtn, takoyakiBtn, gyeranppangBtn, hotteokBtn]
        
        for buttonIndex in buttons.indices {
            buttons[buttonIndex].isSelected = (buttonIndex == index)
        }
    }
    
    func setFieldEmptyMode(isEmpty: Bool) {
        if isEmpty {
            nameField.layer.borderColor = UIColor.init(r: 223, g: 223, b: 223).cgColor
        } else {
            nameField.layer.borderColor = UIColor.init(r: 243, g: 162, b: 169).cgColor
        }
    }
    
    func hideRegisterBtn() {
        if registerBtnBg.alpha != 0 {
            let originalBgTransform = self.registerBtnBg.transform
            let originalBtnTransform = self.registerBtn.transform
            
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
                self?.registerBtnBg.transform = originalBgTransform.translatedBy(x: 0.0, y: 90)
                self?.registerBtnBg.alpha = 0
                
                self?.registerBtn.transform = originalBtnTransform.translatedBy(x: 0.0, y: 90)
                self?.registerBtn.alpha = 0
            })
        }
    }
    
    func showRegisterBtn() {
        if registerBtnBg.alpha != 1 {
            let originalBgTransform = self.registerBtnBg.transform
            let originalBtnTransform = self.registerBtn.transform
            
            UIView.animateKeyframes(withDuration: 0.2, delay: 0, animations: { [weak self] in
                self?.registerBtnBg.transform = originalBgTransform.translatedBy(x: 0.0, y: -90)
                self?.registerBtnBg.alpha = 1
                
                self?.registerBtn.transform = originalBtnTransform.translatedBy(x: 0.0, y: -90)
                self?.registerBtn.alpha = 1
            })
        }
    }
    
    func getCategory() -> StoreCategory? {
        if bungeoppangBtn.isSelected {
            return .BUNGEOPPANG
        } else if takoyakiBtn.isSelected {
            return .TAKOYAKI
        } else if gyeranppangBtn.isSelected {
            return .GYERANPPANG
        } else if hotteokBtn.isSelected {
            return .HOTTEOK
        } else {
            return nil
        }
    }
}

extension WritingView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hideRegisterBtn()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.showRegisterBtn()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.showRegisterBtn()
    }
}
