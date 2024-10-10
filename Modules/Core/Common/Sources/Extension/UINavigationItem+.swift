import UIKit

public extension UIBarButtonItem {
    convenience init(spacing: Int) {
        self.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        width = CGFloat(spacing)
    }
}

public extension UINavigationItem {
    func setAutoInsetRightBarButtonItems(_ items: [UIBarButtonItem], animated: Bool) {
        var barButtonItems: [UIBarButtonItem] = []
        barButtonItems.append(UIBarButtonItem(spacing: 0))
        for item in items {
            barButtonItems.append(item)
            barButtonItems.append(UIBarButtonItem(spacing: 12))
        }
        setRightBarButtonItems(barButtonItems, animated: animated)
    }

    func setAutoInsetRightBarButtonItem(_ item: UIBarButtonItem?) {
        guard let item = item else {
            rightBarButtonItems = nil
            return
        }

        setAutoInsetRightBarButtonItems([item], animated: false)
    }

    func setAutoInsetLeftBarButtonItems(_ items: [UIBarButtonItem], animated: Bool) {
        var barButtonItems: [UIBarButtonItem] = []
        barButtonItems.append(UIBarButtonItem(spacing: 0))
        for item in items {
            barButtonItems.append(item)
            barButtonItems.append(UIBarButtonItem(spacing: 12))
        }
        setLeftBarButtonItems(barButtonItems, animated: animated)
    }

    func setAutoInsetLeftBarButtonItem(_ item: UIBarButtonItem?) {
        guard let item = item else {
            leftBarButtonItems = nil
            return
        }

        setAutoInsetLeftBarButtonItems([item], animated: false)
    }
}
