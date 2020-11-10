//
//  Notifications.swift
//  VGINV
//
//  Created by Zohaib on 7/27/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

struct Notifications: Codable {
    var success: Bool?
    var notifications: [AllNotifications]
    
    enum CodingKeys: String, CodingKey {
        case notifications = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notifications = try container.decode([AllNotifications].self, forKey: .notifications)
    }
}

struct AllNotifications: Codable {
    var id: String?
    var type: String?
    var notificationData: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", type = "type", notificationData = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        notificationData = try container.decodeIfPresent(String.self, forKey: .notificationData)
    }
}

extension AllNotifications: Equatable {}
func ==(left: AllNotifications, right: AllNotifications) -> Bool {
    return left.id == right.id
}
