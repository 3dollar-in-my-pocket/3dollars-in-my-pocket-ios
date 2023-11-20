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
            guard let fcmOptions = request.content.userInfo["fcm_options"] as? [String: Any],
                  let urlImageString = fcmOptions["image"] as? String,
                  let fileURL = URL(string: urlImageString),
                  let imageData = try? Data(contentsOf: fileURL) else {
                contentHandler(bestAttemptContent)
                return
            }
            print("fileUrl: \(fileURL)")
            
            guard let attachment = self.saveImageToDisk(
                    fileIdentifier: "image.jpg",
                    data: imageData,
                    options: nil
            ) else {
                print("error in UNNotificationAttachment.saveImageToDisk()")
                contentHandler(bestAttemptContent)
                return
            }
            
            bestAttemptContent.attachments = [ attachment ]
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler,
           let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func saveImageToDisk(
        fileIdentifier: String,
        data: Data,
        options: [NSObject: AnyObject]?
    ) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(
                at: folderURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            let fileURL = folderURL.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL, options: [])
            let attachment = try UNNotificationAttachment(
                identifier: fileIdentifier,
                url: fileURL,
                options: options
            )
            
            return attachment
        } catch let error {
            print("Error in saveImageToDisk: \(error)")
        }
        
        return nil
    }
}
