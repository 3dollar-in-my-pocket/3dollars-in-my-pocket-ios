import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, tableName: "Localization", value: self, comment: "")
  }
}
