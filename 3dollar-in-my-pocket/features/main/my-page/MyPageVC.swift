import UIKit

class MyPageVC: BaseVC {
    
    private lazy var myPageView = MyPageView(frame: self.view.frame)
    private var viewModel = MyPageViewModel()
    
    static func instance() -> MyPageVC {
        return MyPageVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = myPageView
        setupRegisterCollectionView()
        setUpReviewTableView()
    }
    
    override func bindViewModel() {
        viewModel.reportedStores.bind(to: myPageView.registerCollectionView.rx.items(cellIdentifier: RegisterCell.registerId, cellType: RegisterCell.self)) { row, store, cell in
            cell.bind(store: store)
        }.disposed(by: disposeBag)
        
        myPageView.modifyBtn.rx.tap.bind { [weak self] in
            if let currentName = self?.myPageView.nicknameLabel.text {
                self?.navigationController?.pushViewController(RenameVC.instance(currentName: currentName), animated: true)
            }
        }.disposed(by: disposeBag)
        
        myPageView.registerTotalBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.pushViewController(RegisteredVC.instance(), animated: true)
        }.disposed(by: disposeBag)
        
        myPageView.reviewTotalBtn.rx.tap.bind { [weak self] in
            self?.navigationController?.pushViewController(MyReviewVC.instance(), animated: true)
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMyInfo()
        getReportedStore()
    }
    
    private func setupRegisterCollectionView() {
        myPageView.registerCollectionView.delegate = self
        myPageView.registerCollectionView.register(RegisterCell.self, forCellWithReuseIdentifier: RegisterCell.registerId)
    }
    
    private func setUpReviewTableView() {
        myPageView.reviewTableView.delegate = self
        myPageView.reviewTableView.dataSource = self
        myPageView.reviewTableView.register(MyPageReviewCell.self, forCellReuseIdentifier: MyPageReviewCell.registerId)
    }
    
    private func getMyInfo() {
        UserService.getUserInfo { [weak self] (response) in
            switch response.result {
            case .success(let user):
                self?.myPageView.nicknameLabel.text = user.nickname
            case .failure(let error):
                if let vc = self {
                    AlertUtils.show(controller: vc, title: "error user info", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func getReportedStore() {
        StoreService.getReportedStore(page: 1) { [weak self] (response) in
            switch response.result {
            case .success(let storePage):
                self?.myPageView.registerCountLabel.text = "\(storePage.totalElements!)개"
                if storePage.content.count > 5 {
                    var sliceArray: [Store?] = Array(storePage.content[0...4])
                    
                    sliceArray.append(nil)
                    self?.viewModel.reportedStores.onNext(sliceArray)
                } else {
                    self?.viewModel.reportedStores.onNext(storePage.content)
                }
            case .failure(let error):
                if let vc = self {
                    AlertUtils.show(controller: vc, title: "get reported store error", message: error.localizedDescription)
                }
            }
        }
    }
}

extension MyPageVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 172, height: 172)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let store = try? self.viewModel.reportedStores.value()[indexPath.row] {
            self.navigationController?.pushViewController(DetailVC.instance(storeId: store.id!), animated: true)
        } else {
            self.navigationController?.pushViewController(RegisteredVC.instance(), animated: true)
        }
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
