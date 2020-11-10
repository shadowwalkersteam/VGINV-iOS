//
//  CitiesCountries.swift
//  VGINV
//
//  Created by Zohaib on 7/22/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

struct Countries: Codable {
    var success: Bool?
    var countries: [CountriesDetails]
    
    enum CodingKeys: String, CodingKey {
        case countries = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        countries = try container.decode([CountriesDetails].self, forKey: .countries)
    }
}

struct Cities: Codable {
    var success: Bool?
    var cities: [CitiesDetails]
    
    enum CodingKeys: String, CodingKey {
        case cities = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cities = try container.decode([CitiesDetails].self, forKey: .cities)
    }
}

struct Departments: Codable {
    var success: Bool?
    var departments: [DepartmentsDetails]
    
    enum CodingKeys: String, CodingKey {
        case departments = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        departments = try container.decode([DepartmentsDetails].self, forKey: .departments)
    }
}

struct DepartmentsDetails: Codable {
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

struct CountriesDetails: Codable {
    var id: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
    }
}

struct CitiesDetails: Codable {
    var id: Int?
    var countryId: Int?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id", name = "city_name", countryId = "country_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        countryId = try container.decode(Int.self, forKey: .countryId)
        name = try container.decode(String.self, forKey: .name)
    }
}
