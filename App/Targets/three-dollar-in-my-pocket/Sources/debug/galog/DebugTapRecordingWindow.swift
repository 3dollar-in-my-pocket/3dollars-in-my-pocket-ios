import UIKit

import DesignSystem

final class DebugTapRecordingWindow: UIWindow {
    private enum Layout {
        static let tapMovementTolerance: CGFloat = 10
        static let snapshotScale: CGFloat = 0.35
        static let markerRadius: CGFloat = 22
    }

    private var touchBeganLocations: [ObjectIdentifier: CGPoint] = [:]

    override func sendEvent(_ event: UIEvent) {
        if event.type == .touches, GALogStore.shared.isRecordingEnabled {
            recordTapIfNeeded(event)
        }
        super.sendEvent(event)
    }

    private func recordTapIfNeeded(_ event: UIEvent) {
        for touch in event.allTouches ?? [] {
            let key = ObjectIdentifier(touch)
            let location = touch.location(in: self)

            switch touch.phase {
            case .began:
                touchBeganLocations[key] = location
            case .ended:
                defer { touchBeganLocations[key] = nil }
                guard let beganLocation = touchBeganLocations[key],
                      hypot(location.x - beganLocation.x, location.y - beganLocation.y) <= Layout.tapMovementTolerance
                else { continue }
                GALogStore.shared.recordTap(makeTapInfo(at: location, touchedView: touch.view))
            case .cancelled:
                touchBeganLocations[key] = nil
            default:
                break
            }
        }
    }

    private func makeTapInfo(at location: CGPoint, touchedView: UIView?) -> DebugTapInfo {
        return DebugTapInfo(
            date: Date(),
            elementDescription: elementDescription(of: touchedView),
            viewControllerName: touchedView.flatMap(owningViewControllerName(of:)),
            snapshot: makeSnapshot(markedAt: location)
        )
    }

    private func elementDescription(of view: UIView?) -> String {
        var current = view
        var anchor = view
        while let candidate = current, candidate !== self {
            if let text = displayText(of: candidate) {
                return "\"\(text)\" \(typeName(of: candidate))"
            }
            if candidate is UIControl || candidate is UICollectionViewCell || candidate is UITableViewCell {
                anchor = candidate
                break
            }
            current = candidate.superview
        }
        return anchor.map(typeName(of:)) ?? "알 수 없음"
    }

    private func displayText(of view: UIView) -> String? {
        if let label = view.accessibilityLabel, label.isEmpty == false {
            return label
        }
        if let button = view as? UIButton {
            let title = button.configuration?.title ?? button.currentTitle ?? button.titleLabel?.text
            if let title, title.isEmpty == false { return title }
        }
        if let label = view as? UILabel, let text = label.text, text.isEmpty == false {
            return text
        }
        return firstLabelText(in: view, depth: 0)
    }

    private func firstLabelText(in view: UIView, depth: Int) -> String? {
        guard depth < 6 else { return nil }
        for subview in view.subviews where subview.isHidden == false {
            if let label = subview as? UILabel, let text = label.text, text.isEmpty == false {
                return text
            }
            if let text = firstLabelText(in: subview, depth: depth + 1) {
                return text
            }
        }
        return nil
    }

    private func typeName(of view: UIView) -> String {
        return String(describing: type(of: view))
    }

    private func owningViewControllerName(of view: UIView) -> String? {
        var responder: UIResponder? = view
        while let current = responder {
            if let viewController = current as? UIViewController,
               (viewController is UINavigationController || viewController is UITabBarController) == false {
                return String(describing: type(of: viewController))
            }
            responder = current.next
        }
        return nil
    }

    private func makeSnapshot(markedAt location: CGPoint) -> UIImage? {
        guard bounds.isEmpty == false else { return nil }
        let format = UIGraphicsImageRendererFormat()
        format.scale = Layout.snapshotScale * (windowScene?.screen.scale ?? 3)
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
        return renderer.image { context in
            drawHierarchy(in: bounds, afterScreenUpdates: false)
            let markerRect = CGRect(
                x: location.x - Layout.markerRadius,
                y: location.y - Layout.markerRadius,
                width: Layout.markerRadius * 2,
                height: Layout.markerRadius * 2
            )
            context.cgContext.setStrokeColor(Colors.mainRed.color.cgColor)
            context.cgContext.setLineWidth(6)
            context.cgContext.strokeEllipse(in: markerRect)
        }
    }
}
