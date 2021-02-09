import Foundation
import UIKit

struct ImageUtils {
  static func cropToBounds(image: UIImage) -> UIImage {
    
    let cgimage = image.cgImage!
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat
    var cgheight: CGFloat
    
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
      posX = ((contextSize.width - contextSize.height) / 2)
      posY = 0
      cgwidth = contextSize.height
      cgheight = contextSize.height
    } else {
      posX = 0
      posY = ((contextSize.height - contextSize.width) / 2)
      cgwidth = contextSize.width
      cgheight = contextSize.width
    }
    
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImage = cgimage.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    
    return image
  }
  
  static func dataArrayFromImages(photos: [UIImage]) -> [Data] {
    let maximumLenth = 10 * 1024 * 1024
    var compressionQuality: CGFloat = 1
    var dataArray: [Data] = []
    
    let bcf = ByteCountFormatter()
    bcf.allowedUnits = [.useMB]
    bcf.countStyle = .file
    
    for photo in photos {
      while photo.jpegData(compressionQuality: compressionQuality)!.count > maximumLenth {
        compressionQuality = compressionQuality - 0.1
      }
      
      let data = photo.jpegData(compressionQuality: compressionQuality)!
      dataArray.append(data)
      Log.debug("photo size: \(bcf.string(fromByteCount: Int64(data.count)))")
    }
    
    return dataArray
  }
}
