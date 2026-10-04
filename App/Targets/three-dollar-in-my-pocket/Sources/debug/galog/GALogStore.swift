import UIKit
import Combine

import Common
import DesignSystem

struct GALogEntry {
    enum Kind {
        case pageView
        case click
        case impression
        case other

        var color: UIColor {
            switch self {
            case .pageView: return Colors.mainGreen.color
            case .click: return Colors.mainPink.color
            case .impression: return Colors.gray40.color
            case .other: return Colors.gray70.color
            }
        }
    }

    let date: Date
    let name: String
    let parameters: [(key: String, value: String)]

    var kind: Kind {
        switch name {
        case GALogStore.pageViewEventName: return .pageView
        case "click": return .click
        case "impression": return .impression
        default: return .other
        }
    }

    var screen: String? { value(for: "screen") ?? value(for: "screen_name") }
    var objectType: String? { value(for: "object_type") }
    var objectId: String? { value(for: "object_id") }

    var target: String? {
        switch (objectType, objectId) {
        case let (type?, id?): return "\(type)/\(id)"
        case let (type?, nil): return type
        case let (nil, id?): return id
        default: return nil
        }
    }

    var extraParameters: [(key: String, value: String)] {
        let summaryKeys: Set<String> = ["screen", "screen_name", "screen_class", "object_type", "object_id"]
        return parameters.filter { summaryKeys.contains($0.key).isNot }
    }

    var collapseKey: String {
        return [name, objectType ?? "", objectId ?? "", kind == .pageView ? screen ?? "" : ""].joined(separator: "|")
    }

    private func value(for key: String) -> String? {
        return parameters.first { $0.key == key }?.value
    }
}

struct DebugTapInfo {
    let date: Date
    let elementDescription: String
    let viewControllerName: String?
    let snapshot: UIImage?
}

final class GALogGroup {
    let id = UUID()
    let startDate: Date
    let tap: DebugTapInfo?
    fileprivate(set) var entries: [GALogEntry]

    init(entry: GALogEntry, tap: DebugTapInfo?) {
        self.startDate = entry.date
        self.tap = tap
        self.entries = [entry]
    }

    func collapsedLines(includesImpression: Bool) -> [(entry: GALogEntry, count: Int)] {
        var lines: [(entry: GALogEntry, count: Int)] = []
        for entry in entries where includesImpression || entry.kind != .impression {
            if let index = lines.firstIndex(where: { $0.entry.collapseKey == entry.collapseKey }) {
                lines[index].count += 1
            } else {
                lines.append((entry, 1))
            }
        }
        return lines
    }
}

final class GALogStore {
    static let shared = GALogStore()
    static let pageViewEventName = "page_view"

    enum Constant {
        static let groupingInterval: TimeInterval = 0.3
        static let tapMatchInterval: TimeInterval = 0.7
        static let maximumEntryCount = 500
    }

    private enum Key {
        static let isRecordingEnabled = "debug.galog.isRecordingEnabled"
        static let isToastEnabled = "debug.galog.isToastEnabled"
        static let isImpressionToastEnabled = "debug.galog.isImpressionToastEnabled"
    }

    let didUpdateGroup = PassthroughSubject<GALogGroup, Never>()
    let didClear = PassthroughSubject<Void, Never>()
    private(set) var groups: [GALogGroup] = []
    private var lastTap: DebugTapInfo?

    var isRecordingEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Key.isRecordingEnabled) as? Bool ?? true }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.isRecordingEnabled)
            if newValue.isNot {
                lastTap = nil
                didClear.send(())
            }
        }
    }

    var isToastEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Key.isToastEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Key.isToastEnabled) }
    }

    var isImpressionToastEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Key.isImpressionToastEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Key.isImpressionToastEnabled) }
    }

    var entryCount: Int {
        return groups.reduce(0) { $0 + $1.entries.count }
    }

    func recordTap(_ tap: DebugTapInfo) {
        guard isRecordingEnabled else { return }
        lastTap = tap
    }

    func record(name: String, parameters: [String: Any]?) {
        guard isRecordingEnabled else { return }
        let date = Date()
        let normalizedParameters = (parameters ?? [:])
            .map { (key: $0.key, value: String(describing: $0.value)) }
            .sorted { $0.key < $1.key }

        DispatchQueue.main.async { [weak self] in
            self?.append(GALogEntry(date: date, name: name, parameters: normalizedParameters))
        }
    }

    func clear() {
        groups.removeAll()
        lastTap = nil
        didClear.send(())
    }

    func group(id: UUID) -> GALogGroup? {
        return groups.first { $0.id == id }
    }

    private func append(_ entry: GALogEntry) {
        let group: GALogGroup
        if let lastGroup = groups.last,
           entry.date.timeIntervalSince(lastGroup.startDate) <= Constant.groupingInterval {
            lastGroup.entries.append(entry)
            group = lastGroup
        } else {
            group = GALogGroup(entry: entry, tap: consumeTap(before: entry.date))
            groups.append(group)
        }

        trimIfNeeded()
        didUpdateGroup.send(group)
    }

    private func consumeTap(before date: Date) -> DebugTapInfo? {
        guard let tap = lastTap else { return nil }
        let interval = date.timeIntervalSince(tap.date)
        guard interval >= 0, interval <= Constant.tapMatchInterval else { return nil }
        lastTap = nil
        return tap
    }

    private func trimIfNeeded() {
        while entryCount > Constant.maximumEntryCount, groups.count > 1 {
            groups.removeFirst()
        }
    }
}
