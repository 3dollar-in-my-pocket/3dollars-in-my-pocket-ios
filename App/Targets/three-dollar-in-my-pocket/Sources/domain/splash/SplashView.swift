import UIKit

import Common
import DesignSystem

import Lottie

final class SplashView: BaseView {
    private let lottie: LottieAnimationView = {
        let lottie = LottieAnimationView(name: "splash")
        lottie.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        lottie.contentMode = .scaleAspectFit
        return lottie
    }()
    
    override func setup() {
        backgroundColor = UIColor(r: 28, g: 28, b: 28)
        addSubViews([lottie])
    }
    
    override func bindConstraints() {
        lottie.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func startAnimation(onCompletion: @escaping (() -> Void)) {
        alpha = 1.0
        lottie.play { [weak self] _ in
            UIView.animate(
                withDuration: 0.5,
                animations: { [weak self] in
                    self?.alpha = 0
                }) { _ in
                    onCompletion()
                }
        }
    }
}
