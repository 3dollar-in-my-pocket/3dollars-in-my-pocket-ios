import Foundation
import UIKit
import Combine
import Then
import Common

/// 커뮤니티/구 선택 팝업
final class CommunityPopularStoreNeighborhoodsViewController: BaseViewController {
    private let backgroundButton = UIButton()

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let headerView = CommunityPopularStoreNeighborhoodsHeaderView()
    private let contentViewController = CommunityPopularStoreNeighborhoodsContentViewController()
    private lazy var contentsNavigationViewController: UINavigationController = {
        let navigationViewController = UINavigationController(rootViewController: contentViewController)
        navigationViewController.isNavigationBarHidden = true
        
        return navigationViewController
    }()
    
    private let viewModel: CommunityPopularStoreNeighborhoodsViewModel
    
    
    init(_ viewModel: CommunityPopularStoreNeighborhoodsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        viewModel.input.firstLoad.send()
    }

    private func setupUI() {
        addChild(contentsNavigationViewController)
        
        view.addSubViews([
            backgroundButton,
            containerView,
        ])
        
        containerView.addSubViews([
            headerView,
            contentsNavigationViewController.view
        ])
        
        backgroundButton.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(containerView.snp.top)
        }
        
        headerView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        contentsNavigationViewController.view.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(headerView.snp.bottom)
        }
        
        view.addSubview(containerView)

        containerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(600)
        }

        view.backgroundColor = .clear

    }

    override func bindEvent() {
        super.bindEvent()

        backgroundButton
            .controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { owner, _ in
                owner.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        headerView.bind(viewModel: viewModel.headerViewModel)
        
        viewModel.output.contentViewModel
            .main
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreNeighborhoodsViewController, viewModel: CommunityPopularStoreNeighborhoodsContentViewModel) in
                owner.contentViewController.bind(viewModel)
            }
            .store(in: &cancellables)

        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { owner, route in
                switch route {
                case .pushDistrict(let viewModel):
                    let contentViewController = CommunityPopularStoreNeighborhoodsContentViewController()
                    contentViewController.bind(viewModel)
                    
                    owner.contentsNavigationViewController.pushViewController(contentViewController, animated: true)
                case .back:
                    owner.contentsNavigationViewController.popViewController(animated: true)
                case .dismiss:
                    owner.dismiss(animated: true)
                }
            }
            .store(in: &cancellables)
        
        viewModel.output.showErrorAlert
            .main
            .withUnretained(self)
            .sink { (owner: CommunityPopularStoreNeighborhoodsViewController, error: Error) in
                owner.showErrorAlert(error: error)
            }
            .store(in: &cancellables)
    }

    private func generateLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6

        return layout
    }
}
