import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    convenience init?(hex: String) {
        let red, green, blue, alpha: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                if hexColor.count == 8 {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
                
                if hexColor.count == 6 {
                    red   = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
                    green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
                    blue  = CGFloat(hexNumber & 0x0000ff) / 255.0
                    
                    self.init(red: red, green: green, blue: blue, alpha: 1)
                    return
                }
            }
        }
        return nil
    }
}
