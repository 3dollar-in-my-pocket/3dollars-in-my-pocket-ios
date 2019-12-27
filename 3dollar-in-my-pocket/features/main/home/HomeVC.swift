import UIKit
import GoogleMaps

class HomeVC: BaseVC {
    
    private lazy var homeView = HomeView(frame: self.view.frame)
    
    
    static func instance() -> HomeVC {
        return HomeVC(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = homeView
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.49838214755165, longitude: 127.02844798564912, zoom: 15)
        
        homeView.mapView.camera = camera
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.49838214755165, longitude: 127.02844798564912)
        marker.title = "닥고약기"
        marker.snippet = "무름표"
        marker.map = homeView.mapView
    }
    
    override func bindViewModel() {
        homeView.mapButton.rx.tap.bind {
            AlertUtils.show(title: "Current position", message: "\(self.homeView.mapView.camera.target)")
        }.disposed(by: disposeBag)
    }
}
