import UIKit

import Common
import Model
import Log

final class TeamInfoViewController: BaseViewController {
    override var screenName: ScreenName {
        return viewModel.output.screenName
    }
    
    private let teamInfoView = TeamInfoView()
    private let viewModel: TeamInfoViewModel
    
    init(viewModel: TeamInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = teamInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input.load.send(())
    }
    
    override func bindEvent() {
        teamInfoView.backButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: TeamInfoViewController, _) in
                owner.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        teamInfoView.instagramButton.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: TeamInfoViewController, _) in
                owner.goToInsta()
            }
            .store(in: &cancellables)
        
        teamInfoView.teamInfoGroupView.adButton.button.controlPublisher(for: .touchUpInside)
            .main
            .withUnretained(self)
            .sink { (owner: TeamInfoViewController, _) in
                owner.showFrontBanner()
            }
            .store(in: &cancellables)
    }
    
    override func bindViewModelOutput() {
        viewModel.output.creatorGroups
            .main
            .withUnretained(self)
            .sink { (owner: TeamInfoViewController, creatorGroups: [CreatorGroupResponse]) in
                owner.teamInfoView.teamInfoGroupView.bind(creatorGroups: creatorGroups)
            }
            .store(in: &cancellables)
        
        viewModel.output.route
            .main
            .withUnretained(self)
            .sink { (owner: TeamInfoViewController, route: TeamInfoViewModel.Route) in
                owner.handleRoute(route)
            }
            .store(in: &cancellables)
    }
    
    private func goToInsta() {
        guard let url = URL(string: "https://www.instagram.com/3dollar_in_my_pocket/") else { return }
        
        UIApplication.shared.open(url)
    }
    
    private func showFrontBanner() {
        Environment.appModuleInterface.showFrontAdmob(adType: .frontBanner, viewController: self)
    }
}

// MARK: Route
extension TeamInfoViewController {
    private func handleRoute(_ route: TeamInfoViewModel.Route) {
        switch route {
        case .showErrorAlert(let error):
            showErrorAlert(error: error)
        }
    }
}
