import UIKit

import Common

final class TeamInfoViewController: BaseViewController {
    private let teamInfoView = TeamInfoView()
    
    override func loadView() {
        view = teamInfoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func goToInsta() {
        guard let url = URL(string: "https://www.instagram.com/3dollar_in_my_pocket/") else { return }
        
        UIApplication.shared.open(url)
    }
    
    private func showFrontBanner() {
        Environment.appModuleInterface.showFrontAdmob(adType: .frontBanner, viewController: self)
    }
}
