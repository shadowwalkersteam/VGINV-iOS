//
//  SideMenu.swift
//  VGINV
//
//  Created by Zohaib on 8/11/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation


struct SideMenu {
    let title: String
}

extension SideMenu {
    static let sideMenuItemsHMG: [SideMenu] = [
        SideMenu(title: "Home"),
        SideMenu(title: "Categories"),
        SideMenu(title: "Deals"),
        SideMenu(title: "My Members"),
        SideMenu(title: "HMG Members"),
        SideMenu(title: "Members Chat"),
        SideMenu(title: "Settings"),
        SideMenu(title: "Switch to VG"),
        SideMenu(title: "Change Password"),
        SideMenu(title: "Profile"),
        SideMenu(title: "Logout")
    ]
    
    static let sideMenuItemsVG: [SideMenu] = [
        SideMenu(title: "Home"),
        SideMenu(title: "Categories"),
        SideMenu(title: "Project"),
        SideMenu(title: "My Members"),
        SideMenu(title: "VG Members"),
        SideMenu(title: "Members Chat"),
        SideMenu(title: "Settings"),
        SideMenu(title: "Switch to VG"),
        SideMenu(title: "Change Password"),
        SideMenu(title: "Profile"),
        SideMenu(title: "Logout")
    ]
    
    static let switchedSideMenuItemsHMG: [SideMenu] = [
        SideMenu(title: "Home"),
        SideMenu(title: "Categories"),
        SideMenu(title: "Deals"),
        SideMenu(title: "My Members"),
        SideMenu(title: "VG Members"),
        SideMenu(title: "Members Chat"),
        SideMenu(title: "Settings"),
        SideMenu(title: "Switch to VG"),
        SideMenu(title: "Change Password"),
        SideMenu(title: "Profile"),
        SideMenu(title: "Logout")
    ]
    
    static let switchedSideMenuItemsVG: [SideMenu] = [
        SideMenu(title: "Home"),
        SideMenu(title: "Categories"),
        SideMenu(title: "Project"),
        SideMenu(title: "My Members"),
        SideMenu(title: "HMG Members"),
        SideMenu(title: "Members Chat"),
        SideMenu(title: "Settings"),
        SideMenu(title: "Switch to HMG"),
        SideMenu(title: "Change Password"),
        SideMenu(title: "Profile"),
        SideMenu(title: "Logout")
    ]
}
