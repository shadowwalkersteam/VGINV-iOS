//
//  ConstantStrings.swift
//  VGINV
//
//  Created by Zohaib on 6/20/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
class ConstantStrings {
    static var appId = "212924ab854667a"
    static var apiKey = "316d2948b9529fe96b6900dd7a91cce6194cd414"
    static var region = "eu"
    
    
    static let BASE_URL = "http://3.17.158.63:3637"
    static let WEBSITE_BASE_URL = "https://app.vginv.com"
    static let WEBSITE_OPEN_URL = "https://www.vginv.com/vg-admin/public"
    
    static let LOGIN_URL = BASE_URL + "/user/login"
    static let GROUP_CHATS = BASE_URL + "/group/chats"
    static let PROFILE_URL = BASE_URL + "/user/me"
    static let NEWS_URL = BASE_URL + "/posts"
    static let ALL_CITIES = BASE_URL + "/cities"
    static let ALL_COUNTRIES = BASE_URL + "/countries"
    static let DEPARTMENTS = BASE_URL + "/departments"
    static let POST_PROJECT = BASE_URL + "/projects"
    static let ALL_USERS = BASE_URL + "/user/friends/add"
    static let USER_ADD_FRIEND = BASE_URL + "/user/friends"
    static let USER_FRIENDS = BASE_URL + "/user/friends"
    static let DELETE_MEMBER = BASE_URL + "/user/unfriend"
    static let NOTIFICATIONS = BASE_URL + "/user/notifications"
    static let ACCEPT_REQUEST = BASE_URL + "/request/"
    static let FRIENDS_PROFILE = BASE_URL + "/user/info/"
    static let USER_TOGGLE = BASE_URL + "/type/toggle"
    static let SWITCH_HMG = BASE_URL + "/user/hmg/request"
    static let LIKE = BASE_URL + "/projects/like"
    static let COMMENT = BASE_URL + "/projects/comment"
    static let INVEST = BASE_URL + "/projects/invest"
    static let CHANGE_PASSWORD = BASE_URL + "/user/settings/password"
    static let CHANGE_PROFILE = BASE_URL + "/user/settings/profile"
    static let ONESIGNAL = "https://onesignal.com/api/v1/notifications"
}
