#if DEBUG
import UIKit

/// 흔들기 제스처 감지만 담당한다. 감지 후 무엇을 할지는 onShake로 위임한다.
final class ShakeDetectingWindow: UIWindow {
    var onShake: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.notificationOccurred(.success)
            onShake?()
        }
        super.motionEnded(motion, with: event)
    }
}
#endif
