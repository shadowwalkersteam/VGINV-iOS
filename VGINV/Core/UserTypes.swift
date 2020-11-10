//
//  UserTypes.swift
//  VGINV
//
//  Created by Zohaib on 7/26/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

class UserTypes {
    static func getUserType(withKey key: String, targetSpecific:Bool) -> String {
        if targetSpecific{
            return NSLocalizedString(key, tableName:"TargetSpecific", comment: "")
        }
        else{
            return NSLocalizedString(key, comment: "")
        }
    }
    
    static func isHMG() -> Bool {
        if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
            return false
        } else if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
            return true
        } else if (!Defaults.readString(key: Defaults.USER_TYPE).isEmpty && Defaults.readString(key: Defaults.USER_TYPE).localizedCaseInsensitiveContains("vg")) {
            return false
        } else {
            return true
        }
    }
    
    static func getUserType() -> String {
        if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty) {
            return Defaults.readString(key: Defaults.TOGGLER_USER_TYPE)
        } else {
            return Defaults.readString(key: Defaults.USER_TYPE)
        }
    }
    
    static func getToggledUserType() -> String {
        if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty) {
            return Defaults.readString(key: Defaults.TOGGLER_USER_TYPE)
        } else {
            return Defaults.readString(key: Defaults.USER_TYPE)
        }
    }
}
