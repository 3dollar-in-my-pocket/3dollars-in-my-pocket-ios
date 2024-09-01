import UIKit

public final class FeedbackGenerator {
    public static let shared = FeedbackGenerator()
    
    public enum Style {
        case impact
        case selection
        case success
        case error
        case warning
    }
    
    private let impactGenerator = UIImpactFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    init() {
        impactGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    public func generate(_ style: Style) {
        switch style {
        case .impact:
            impactGenerator.impactOccurred()
        case .selection:
            selectionGenerator.selectionChanged()
        case .success:
            notificationGenerator.notificationOccurred(.success)
        case .error:
            notificationGenerator.notificationOccurred(.error)
        case .warning:
            notificationGenerator.notificationOccurred(.warning)
        }
    }
}
