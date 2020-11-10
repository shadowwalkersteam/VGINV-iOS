//
//  MembersChat.swift
//  VGINV
//
//  Created by Zohaib on 7/12/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

struct Groups: Codable {
    var success: Bool?
    var groupChats: [GroupChats]
    
    enum CodingKeys: String, CodingKey {
        case groupChats = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupChats = try container.decode([GroupChats].self, forKey: .groupChats)
    }
}

struct GroupChats: Codable {
    var id: Int?
    var message: String?
    var senderType: String?
    var createdAt: String?
    var groupChatSender: GroupChatSender?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", message = "message", senderType = "sender_type", createdAt = "created_at" , groupChatSender = "sender"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        message = try container.decode(String.self, forKey: .message)
        senderType = try container.decode(String.self, forKey: .senderType)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        groupChatSender = try container.decode(GroupChatSender.self, forKey: .groupChatSender)
    }
}

struct GroupChatSender: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", firstName = "first_name", lastName = "last_name", image = "image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        image = try container.decode(String.self, forKey: .image)
    }
}

extension GroupChatSender {
    var urlToSourceLogo: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + image!
    }
}

extension GroupChats {
    var urlToMedia: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + message!
    }
}
