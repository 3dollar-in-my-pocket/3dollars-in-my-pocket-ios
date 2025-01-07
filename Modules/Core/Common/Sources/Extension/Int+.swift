import Foundation

public extension Int {
    var decimalFormat: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))
    }
    
    var distanceString: String {
        if self < 1000 {
            return "\(self)m"
        } else if self >= 1000 && self < 10000 {
            return "\(self / 1000)km"
        } else {
            return "10km+"
        }
    }
}
