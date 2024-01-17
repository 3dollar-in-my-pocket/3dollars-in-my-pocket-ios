import UIKit

import Lottie

final class LoadingView: UIView {
    let lottieView: LottieAnimationView = {
        let lottieView = LottieAnimationView(name: "loading", bundle: Bundle.frameworkBundle)
        lottieView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.translatesAutoresizingMaskIntoConstraints = false

        return lottieView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
        bindConstraints()
    }

    func startLoading() {
        lottieView.play()
    }

    func stopLoading() {
        lottieView.stop()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(lottieView)
    }

    private func bindConstraints() {
        lottieView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lottieView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lottieView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        lottieView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
}
