import UIKit

import DesignSystem

final class WriteNavigationController: UINavigationController {
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.trackTintColor = Colors.gray30.color
        progressView.tintColor = Colors.mainPink.color
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
    }
    
    private func setupUI() {
        navigationBar.addSubview(progressView)
        
        progressView.snp.makeConstraints {
            $0.leading.equalTo(navigationBar)
            $0.trailing.equalTo(navigationBar)
            $0.bottom.equalTo(navigationBar)
            $0.height.equalTo(2)
        }
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: Colors.gray100.color,
            .font: DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        ]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    func updateProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
