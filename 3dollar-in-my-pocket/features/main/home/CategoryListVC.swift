import UIKit
import GoogleMaps

class CategoryListVC: BaseVC {
    
    private lazy var categoryListView = CategoryListView(frame: self.view.frame)
    
    
    static func instance() -> CategoryListVC {
        return CategoryListVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = categoryListView
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
        
        categoryListView.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
        marker.title = "닥고약기"
        marker.snippet = "무름표"
        marker.map = categoryListView.mapView
        
        categoryListView.tableView.delegate = self
        categoryListView.tableView.dataSource = self
        categoryListView.tableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.registerId)
    }
    
    override func bindViewModel() {
        
    }
}

extension CategoryListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.registerId, for: indexPath) as? CategoryListCell else {
            return BaseTableViewCell()
        }
        
        return cell
    }
}
