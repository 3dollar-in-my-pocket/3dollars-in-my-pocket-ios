//
//  NotificationService.swift
//  service-extension
//
//  Created by Hyun Sik Yoo on 2022/01/21.
//  Copyright © 2022 Macgongmon. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = self.bestAttemptContent {
            var urlString:String? = nil
            if let urlImageString = request.content.userInfo["urlImageString"] as? String {
                urlString = urlImageString
            }
            
            if let imagePath = DownloadManager.image(imageURLString) {
                let imageURL = URL(fileURLWithPath: imagePath)
                
                do {
                    
                    let attach = try UNNotificationAttachment(identifier: "image-test", url: imageURL, options: nil)
                    
                    bestAttemptContent.attachments = [attach]
                    
                } catch {
                    
                    print(error)
                    
                }
                
            }
            
            if urlString != nil, let fileUrl = URL(string: urlString!) {
                print("fileUrl: \(fileUrl)")
                
                guard let imageData = NSData(contentsOf: fileUrl) else {
                    contentHandler(bestAttemptContent)
                    return
                }
                guard let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: "image.jpg", data: imageData, options: nil) else {
                    print("error in UNNotificationAttachment.saveImageToDisk()")
                    contentHandler(bestAttemptContent)
                    return
                }
                
                bestAttemptContent.attachments = [ attachment ]
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}
