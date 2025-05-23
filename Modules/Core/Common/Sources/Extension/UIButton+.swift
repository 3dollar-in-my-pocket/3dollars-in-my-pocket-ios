import UIKit

import Model
import ZMarkupParser
import Kingfisher

public extension UIButton {
    func setSDButton(_ sdButton: SDButton) {
        setTitleColor(UIColor(hex: sdButton.text.fontColor), for: .normal)
        
        if sdButton.text.isHtml {
            let attributedText = ZHTMLParserBuilder.initWithDefault().build().render(sdButton.text.text)
            setAttributedTitle(attributedText, for: .normal)
        } else {
            setTitle(sdButton.text.text, for: .normal)
        }
        
        
        if let image = sdButton.image,
           let imageUrl = URL(string: image.url) {
            let resizeProcessor = ResizingImageProcessor(
                referenceSize: CGSize(width: image.style.width, height: image.style.height),
                mode: .aspectFit
            )
            
            kf.setImage(with: imageUrl, for: .normal, options: [.processor(resizeProcessor)])
        }
        
        backgroundColor = UIColor(hex: sdButton.style.backgroundColor)
    }
}
