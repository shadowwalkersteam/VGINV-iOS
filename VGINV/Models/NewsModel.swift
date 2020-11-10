//
//  NewsModel.swift
//  VGINV
//
//  Created by Zohaib on 7/19/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

struct NewsModel: Codable {
    var success: Bool?
    var news: [NewsDetails]
    
    enum CodingKeys: String, CodingKey {
        case news = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        news = try container.decode([NewsDetails].self, forKey: .news)
    }
}

struct NewsDetails: Codable {
    var id: Int?
    var title: String?
    var titleAr: String?
    var content: String?
    var contentAr: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", title = "title", titleAr = "title_ar", content = "content" , contentAr = "content_ar", image = "image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        titleAr = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        contentAr = try container.decode(String.self, forKey: .contentAr)
        image = try container.decode(String.self, forKey: .image)
    }
}

extension NewsDetails {
    var newsImage: String {
        return ConstantStrings.WEBSITE_OPEN_URL + "/" + image!
    }
}
