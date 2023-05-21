//
//  MedalResponse.swift
//  3dollar-in-my-pocket
//
//  Created by Hyun Sik Yoo on 2021/12/09.
//  Copyright © 2021 Macgongmon. All rights reserved.
//

import Foundation

struct MedalResponse: Decodable {
    let acquisition: MedalAcquisitionResponse
    let iconUrl: String
    let introduction: String
    let disableIconUrl: String
    let medalId: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case acquisition
        case iconUrl
        case introduction
        case disableIconUrl
        case medalId
        case name
    }
    
    init() {
        self.acquisition = MedalAcquisitionResponse()
        self.iconUrl = ""
        self.introduction = ""
        self.disableIconUrl = ""
        self.medalId = -1
        self.name = ""
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.acquisition = try values.decodeIfPresent(
            MedalAcquisitionResponse.self,
            forKey: .acquisition
        ) ?? MedalAcquisitionResponse()
        self.iconUrl = try values.decodeIfPresent(String.self, forKey: .iconUrl) ?? ""
        self.introduction = try values.decodeIfPresent(String.self, forKey: .introduction) ?? ""
        self.disableIconUrl = try values.decodeIfPresent(
            String.self,
            forKey: .disableIconUrl
        ) ?? ""
        self.medalId = try values.decodeIfPresent(Int.self, forKey: .medalId) ?? -1
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
    }
}

extension MedalResponse {
    struct MedalAcquisitionResponse: Decodable {
        let description: String
        
        enum CodingKeys: String, CodingKey {
            case description
        }
        
        init() {
            self.description = ""
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        }
    }
}
