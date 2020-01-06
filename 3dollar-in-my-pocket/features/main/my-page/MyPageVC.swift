import UIKit

class MyPageVC: BaseVC {
    
    private lazy var myPageView = MyPageView(frame: self.view.frame)
    
    
    static func instance() -> MyPageVC {
        return MyPageVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = myPageView
        myPageView.registerCollectionView.delegate = self
        myPageView.registerCollectionView.dataSource = self
        myPageView.registerCollectionView.register(RegisterCell.self, forCellWithReuseIdentifier: RegisterCell.registerId)
        
        myPageView.reviewTableView.delegate = self
        myPageView.reviewTableView.dataSource = self
        myPageView.reviewTableView.register(MyPageReviewCell.self, forCellReuseIdentifier: MyPageReviewCell.registerId)
    }
    
    override func bindViewModel() {
        
    }
}

extension MyPageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RegisterCell.registerId, for: indexPath) as? RegisterCell else {
            return BaseCollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 172, height: 172)
    }
}

extension MyPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageReviewCell.registerId, for: indexPath) as? MyPageReviewCell else {
            return BaseTableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.setTopRadius()
            cell.setEvenBg()
        case 1:
            cell.setOddBg()
        case 2:
            cell.setBottomRadius()
            cell.setEvenBg()
        default:
            break
        }
        
        return cell
    }
    
    
}
