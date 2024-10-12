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
            
            if let data = photo.jpegData(compressionQuality: compressionQuality),
               let downSampledData = downsampledImage(data: data, size: CGSize(width: 1024, height: 1024))?.jpegData(compressionQuality: compressionQuality) {
                dataArray.append(downSampledData)
            }
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
    
    static func downsampledImage(data: Data?, size: CGSize, cacheImmediately: Bool = true) -> UIImage? {
        guard let data = data else { return nil }
        let createOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        return downsampledImage(source: CGImageSourceCreateWithData(data as CFData, createOptions),
                                size: size,
                                cacheImmediately: cacheImmediately)
    }

    static func downsampledImage(source: CGImageSource?, size: CGSize, cacheImmediately: Bool = true) -> UIImage? {
        guard let imageSource = source else {
            return nil
        }
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                  kCGImageSourceShouldCacheImmediately: cacheImmediately,
                                  kCGImageSourceCreateThumbnailWithTransform: true,
                                  kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)] as CFDictionary
        guard let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else {
            return nil
        }
        return UIImage(cgImage: image)
    }
}
