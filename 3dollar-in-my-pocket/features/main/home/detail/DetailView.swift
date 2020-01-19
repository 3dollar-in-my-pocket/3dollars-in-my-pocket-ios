import UIKit
import GoogleMaps

class DetailView: BaseView {
    
    let navigationBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    let backBtn = UIButton().then {
        $0.setImage(UIImage.init(named: "ic_back_black"), for: .normal)
    }
    
    let titleLabel = UILabel().then {
        $0.text = "강남역 10번 출구"
        $0.textColor = UIColor.init(r: 51, g: 51, b: 51)
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 16)
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.backgroundColor = .white
        $0.rowHeight = UITableView.automaticDimension
        $0.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
    }
    
    lazy var dimView = UIView(frame: self.frame).then {
        $0.backgroundColor = .clear
    }
    
    override func setup() {
        setupNavigationBarShadow()
        navigationBar.addSubViews(backBtn, titleLabel)
        addSubViews(tableView, navigationBar)
    }
    
    override func bindConstraints() {
        navigationBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(98)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(48)
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn.snp.centerY)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom).offset(-20)
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
    
    func addBgDim() {
        DispatchQueue.main.async { [weak self] in
            if let vc = self {
                vc.addSubview(vc.dimView)
                UIView.animate(withDuration: 0.3) {
                    vc.dimView.backgroundColor = UIColor.init(r: 0, g: 0, b: 0, a:0.3)
                }
            }
            
        }
    }
    
    
    func removeBgDim() {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.3, animations: {
                self?.dimView.backgroundColor = .clear
            }) { (_) in
                self?.dimView.removeFromSuperview()
            }
        }
    }
    
}
