//
//  AppHelper.swift
//  VGINV
//
//  Created by Zohaib on 7/5/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation

class AppHelper {
    static func getLocalized(withKey key: String, targetSpecific:Bool) -> String {
        if targetSpecific{
            return NSLocalizedString(key, tableName:"TargetSpecific", comment: "")
        }
        else{
            return key.l10n()
//            return NSLocalizedString(key, comment: "")
        }
    }
    
    static func getLocalizedArray(withKey key: String, targetSpecific:Bool) -> [String] {
        return getLocalized(withKey: key, targetSpecific: targetSpecific).components(separatedBy: ",")
    }
}
