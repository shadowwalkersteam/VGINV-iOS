//
//  Movie.swift
//  CollectionViewResponsiveLayout
//
//  Created by Alfian Losari on 2/8/19.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import UIKit

struct Movie {
    
    let title: String
    let description: String
    let posterImage: UIImage?
        
}

extension Movie {
    
    static let dummyMovies: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "VGSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "Deals".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    static let dummyMoviesVg: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "HmgSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "projects".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    static let switchedDummyMovies: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "VGSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "Deals".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    static let switchedDummyMoviesVG: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "HmgSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "projects".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
}
