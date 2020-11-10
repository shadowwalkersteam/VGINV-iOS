//
//  UserDefaults.swift
//  VGINV
//
//  Created by Zohaib on 7/5/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

struct Defaults {
    
    static let TOKEN = "TOKEN";
    static let IS_LOGGEDIN = "IS_LOGGEDIN";
    public static let USER_ID = "USER_ID";
    static let USER_NAME = "USER_NAME";
    static let USER_DESIGNATION = "USER_DESIGNATION";
    static let USER_PORIFLE_PIC = "USER_PORIFLE_PIC";
    static let USER_TYPE = "USER_TYPE";
    static let LOGGED_IN_USER_TYPE = "USER_LOGGED_IN";
    static let TOGGLER_USER_TYPE = "TOGGLER_USER_TYPE";
    static let EMAIL = "EMAIL";
    static let PASSWORD = "PASSWORD";
    static let LANGUAGE = "LANGUAGE";
    static let SWITCH_POPUP = "SWITCH_POPUP";
    static let UNREAD_COUNTS = "UNREAD_COUNTS";
    static let MESSAGE_TIME = "MESSAGE_TIME";
    static let SESSION_TIME = "SESSION_TIME";
    
    private static let userDefault = UserDefaults.standard
    
    
    static func saveString(key: String, value: String) {
        userDefault.set(value, forKey: key)
    }
    
    static func saveBoolena(key: String, value: Bool) {
        userDefault.set(value, forKey: key)
    }
    
    static func saveInteger(key: String, value: Int) {
        userDefault.set(value, forKey: key)
    }
    
    static func readString(key: String) -> String {
        return userDefault.string(forKey: key) ?? ""
    }
    
    static func readBool(key: String) -> Bool {
        return userDefault.bool(forKey: key)
    }
    
    static func readInteger(key: String) -> Int {
        return userDefault.integer(forKey: key)
    }
}
