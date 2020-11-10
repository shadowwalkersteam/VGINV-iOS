//
//  UserProfile.swift
//  VGINV
//
//  Created by Zohaib on 7/18/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

struct AllUsers: Codable {
    var success: Bool?
    var users: [AllUsersData]
    
    enum CodingKeys: String, CodingKey {
        case users = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        users = try container.decode([AllUsersData].self, forKey: .users)
    }
}

struct AllUsersData: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var position: String?
    var description: String? = ""
    var type: String?
    var updatedAt: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", firstName = "first_name", lastName = "last_name", email = "email" , phone = "phone", description = "description", position = "position", type = "type", updatedAt = "updated_at", image = "image"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        position = try container.decodeIfPresent(String.self, forKey: .position)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}

struct UserProfile: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var position: String?
    var description: String?
    var type: String?
    var updatedAt: String?
    var image: String?
    var city: City?
    var deals: [DealsCatalog]?
    var projects: [ProjectsCatalog]?
    var departments: [ProfileDepartments]
    
    enum CodingKeys: String, CodingKey {
        case id = "id", firstName = "first_name", lastName = "last_name", email = "email" , phone = "phone", description = "description", position = "position", type = "type", updatedAt = "updated_at", image = "image", city = "City", deals = "DealsCatalog", projects = "ProjectsCatalog", departments = "Department_Users"
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        phone = try container.decodeIfPresent(String.self, forKey: .phone) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description)  ?? ""
        position = try container.decodeIfPresent(String.self, forKey: .position)  ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
        image = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        city = try container.decodeIfPresent(City.self, forKey: .city)
        deals = try container.decodeIfPresent([DealsCatalog].self, forKey: .deals)
        projects = try container.decodeIfPresent([ProjectsCatalog].self, forKey: .projects)
        departments = try container.decodeIfPresent([ProfileDepartments].self, forKey: .departments) ?? []
    }
}

struct ProfileDepartments: Codable {
    var departments: Department
    
    enum CodingKeys: String, CodingKey {
        case departments = "Department"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        departments = try container.decode(Department.self, forKey: .departments)
    }
}

struct Department: Codable {
    var id: Int?
    var depEn: String?
    var depAr: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", depEn = "dep_en", depAr = "dep_ar"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        depEn = try container.decode(String.self, forKey: .depEn)
        depAr = try container.decode(String.self, forKey: .depAr)
    }
}

struct City: Codable {
    var id: Int?
    var cityName: String?
    var countryId: Int?
    var country: Country?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", cityName = "city_name", countryId = "country_id", country = "Country"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        cityName = try container.decodeIfPresent(String.self, forKey: .cityName) ?? ""
        countryId = try container.decodeIfPresent(Int.self, forKey: .countryId) ?? 0
        country = try container.decodeIfPresent(Country.self, forKey: .country)
    }
}

struct Country: Codable {
    var id: Int?
    var countryName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", countryName = "name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        countryName = try container.decodeIfPresent(String.self, forKey: .countryName) ?? ""
    }
}

struct DealsCatalog: Codable {
    var id: Int?
    var status: Int?
    var title: String?
    var auth: Int?
    var description: String?
    var budget: Int?
    var investment: Int?
    var image: String?
    var depId: Int?
    var projectAssets: [ProjectAssets]
    var projectLikes: [ProjectLikes]
    var projectComments: [ProjectComments]
    
    enum CodingKeys: String, CodingKey {
        case id = "id", status = "status", title = "title", auth = "auth", description = "description", budget = "budget", investment = "investment", image = "image", depId = "dep_id", projectAssets = "ProjectAssets", projectLikes = "ProjectLikes", projectComments = "ProjectComments"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        auth = try container.decodeIfPresent(Int.self, forKey: .auth)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        budget = try container.decodeIfPresent(Int.self, forKey: .budget)
        investment = try container.decodeIfPresent(Int.self, forKey: .investment)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        depId = try container.decodeIfPresent(Int.self, forKey: .depId)
        projectAssets = try container.decodeIfPresent([ProjectAssets].self, forKey: .projectAssets) ?? []
        projectLikes = try container.decodeIfPresent([ProjectLikes].self, forKey: .projectLikes) ?? []
        projectComments = try container.decodeIfPresent([ProjectComments].self, forKey: .projectComments) ?? []
    }
}

struct ProjectsCatalog: Codable {
    var id: Int?
    var status: Int?
    var title: String?
    var auth: Int?
    var description: String?
    var budget: Int?
    var investment: Int?
    var image: String?
    var depId: Int?
    var projectAssets: [ProjectAssets]
    var projectLikes: [ProjectLikes]
    var projectComments: [ProjectComments]
    
    enum CodingKeys: String, CodingKey {
        case id = "id", status = "status", title = "title", auth = "auth", description = "description", budget = "budget", investment = "investment", image = "image", depId = "dep_id", projectAssets = "ProjectAssets", projectLikes = "ProjectLikes", projectComments = "ProjectComments"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        auth = try container.decodeIfPresent(Int.self, forKey: .auth)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        budget = try container.decodeIfPresent(Int.self, forKey: .budget)
        investment = try container.decodeIfPresent(Int.self, forKey: .investment)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        depId = try container.decodeIfPresent(Int.self, forKey: .depId)
        projectAssets = try container.decodeIfPresent([ProjectAssets].self, forKey: .projectAssets) ?? []
        projectLikes = try container.decodeIfPresent([ProjectLikes].self, forKey: .projectLikes) ?? []
        projectComments = try container.decodeIfPresent([ProjectComments].self, forKey: .projectComments) ?? []
    }
}

struct ProjectAssets: Codable {
    var id: Int?
    var path: String?
    var filePath: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", path = "path"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        path = try container.decode(String.self, forKey: .path)
    }
}

struct ProjectLikes: Codable {
    var id: Int?
    var projectId: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id", projectId = "project_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        projectId = try container.decode(Int.self, forKey: .projectId)
    }
}

struct ProjectComments: Codable {
    var id: Int?
    var projectId: Int?
    var comment: String?
    var commentUsers: CommentUsers?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id", projectId = "project_id", comment = "comment", commentUsers = "User"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        projectId = try container.decodeIfPresent(Int.self, forKey: .projectId)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        commentUsers = try container.decodeIfPresent(CommentUsers.self, forKey: .commentUsers)
    }
}

struct CommentUsers: Codable {
      var firstName: String?
      var lastName: String?
    var image: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name", lastName = "last_name", image = "image"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
         image = try container.decodeIfPresent(String.self, forKey: .image)
    }
}

extension UserProfile {
    var profilePicURL: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + image!
    }
}

extension DealsCatalog {
    var dealsImage: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + image!
    }
}

extension ProjectsCatalog {
    var projectsImage: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + image!
    }
}

extension AllUsersData {
    var userImage: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + image!
    }
}

extension AllUsersData: Equatable {}
func ==(left: AllUsersData, right: AllUsersData) -> Bool {
    return left.id == right.id
}

extension CommentUsers {
    var profilePicURL: String {
        return ConstantStrings.WEBSITE_BASE_URL + "/" + image!
    }
}

extension ProjectAssets {
    var absoluteFilePath: String {
        return ConstantStrings.WEBSITE_BASE_URL + path!
    }
}
