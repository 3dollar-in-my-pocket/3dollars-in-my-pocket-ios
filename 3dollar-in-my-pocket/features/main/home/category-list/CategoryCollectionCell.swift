import UIKit

class CategoryCollectionCell: BaseCollectionViewCell {
    
    static let registerId = "\(CategoryCollectionCell.self)"
    
    let descLabel1 = UILabel().then {
        $0.text = "붕어빵"
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 24)
    }
    
    let descLabel2 = UILabel().then {
        $0.text = "만나기 30초 전"
        $0.textColor = .black
        $0.font = UIFont.init(name: "SpoqaHanSans-Light", size: 24)
    }
    
    let nearOrderBtn = UIButton().then {
        $0.setTitle("거리순", for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    let reviewOrderBtn = UIButton().then {
        $0.setTitle("리뷰순", for: .normal)
        $0.setTitleColor(.black, for: .selected)
        $0.setTitleColor(UIColor.init(r: 189, g: 189, b: 189), for: .normal)
        $0.titleLabel?.font = UIFont.init(name: "SpoqaHanSans-Bold", size: 14)
    }
    
    let tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = UIColor.init(r: 245, g: 245, b: 245)
        $0.tableFooterView = UIView()
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.showsVerticalScrollIndicator = false
    }

    override func setup() {
        addSubViews(descLabel1, descLabel2, nearOrderBtn, reviewOrderBtn, tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.registerId)
    }
    
    override func bindConstraints() {
        descLabel1.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(41)
            make.left.equalToSuperview().offset(24)
        }
        
        descLabel2.snp.makeConstraints { (make) in
            make.centerY.equalTo(descLabel1.snp.centerY)
            make.left.equalTo(descLabel1.snp.right).offset(5)
        }
        
        reviewOrderBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-25)
            make.top.equalToSuperview().offset(49)
        }
        
        nearOrderBtn.snp.makeConstraints { (make) in
            make.right.equalTo(reviewOrderBtn.snp.left).offset(-16)
            make.centerY.equalTo(reviewOrderBtn.snp.centerY)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(descLabel1.snp.bottom).offset(24)
        }
    }
}

extension CategoryCollectionCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.registerId, for: indexPath) as? CategoryListCell else {
            return BaseTableViewCell()
        }
        
        cell.setBottomRadius(isLast: tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row)
        if indexPath.row % 2 == 0 {
            cell.setEvenBg()
        } else {
            cell.setOddBg()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.navigationController?.pushViewController(DetailVC.instance(), animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return CategoryListHeaderView()
    }
}
