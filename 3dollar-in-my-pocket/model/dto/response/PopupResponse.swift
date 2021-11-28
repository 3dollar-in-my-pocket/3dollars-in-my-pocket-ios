//
//  PopupResponse.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/11/26.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct PopupResponse: Decodable {
    let createdAt: String
    let imageUrl: String
    let linkUrl: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case imageUrl
        case linkUrl
        case updatedAt
    }
    
    init() {
        self.createdAt = ""
        self.imageUrl = ""
        self.linkUrl = ""
        self.updatedAt = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        self.imageUrl = try values.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        self.linkUrl = try values.decodeIfPresent(String.self, forKey: .linkUrl) ?? ""
        self.updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
}
