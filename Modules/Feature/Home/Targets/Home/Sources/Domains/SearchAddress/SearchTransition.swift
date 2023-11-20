import UIKit

final class SearchTransition: NSObject {
    let duration = 0.3
    var maskView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
    }
    var maskOriginalFrame = CGRect.zero
    var transitionMode: PresentTransitionMode = .present
    
    enum PresentTransitionMode: Int {
        case present, dismiss
    }
}

extension SearchTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if self.transitionMode == .present {
            if let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) {
                presentedView.alpha = 0
                containerView.addSubview(maskView)
                containerView.addSubview(presentedView)
                
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                    self.maskView.frame = presentedView.frame
                    presentedView.alpha = 1
                } completion: { isSuccess in
                    transitionContext.completeTransition(isSuccess)
                }
            }
        } else {
            if let returningView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                    self.maskView.frame = self.maskOriginalFrame
                    returningView.alpha = 0
                } completion: { [weak self] isSuccess in
                    returningView.removeFromSuperview()
                    self?.maskView.removeFromSuperview()
                    transitionContext.completeTransition(isSuccess)
                }
            }
        }
    }
}
