import UIKit

public class HomeViewController: UIViewController {
    private let homeView = HomeView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func instance() -> HomeViewController {
        return HomeViewController()
    }
    
    public override func loadView() {
        view = homeView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
}
