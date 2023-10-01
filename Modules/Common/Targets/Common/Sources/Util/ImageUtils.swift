import UIKit
import Photos

public struct ImageUtils {
    public static func dataArrayFromImages(photos: [UIImage]) -> [Data] {
        let maximumLenth = 10 * 1024 * 1024
        var compressionQuality: CGFloat = 0.5
        var dataArray: [Data] = []
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        
        for photo in photos {
            while photo.jpegData(compressionQuality: compressionQuality)!.count > maximumLenth {
                compressionQuality -= 0.1
            }
            
            let data = photo.jpegData(compressionQuality: compressionQuality)!
            dataArray.append(data)
        }
        
        return dataArray
    }
    
    public static func getImage(from asset: PHAsset) -> UIImage {
        let options = PHImageRequestOptions()
        var resultImage = UIImage()
        
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
            contentMode: .aspectFit,
            options: options
        ) { (image, _) in
            guard let image = image else { return }
            
            resultImage = image
        }
        
        return resultImage
    }
}
