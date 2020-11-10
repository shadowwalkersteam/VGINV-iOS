//
//  UIColorExt.swift
//  VGINV
//
//  Created by Zohaib on 6/18/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }
    
    class func newLogin() -> UIColor {
        return UIColor(rgb: 0x465a6e)
    }

    class func loginButton() -> UIColor {
        return UIColor(rgb: 0x568ccd)
    }
    
    class func colorPrimary() -> UIColor {
        return UIColor(rgb: 0x4a69ff)
    }
    
    class func dashboardBackground() -> UIColor {
        return UIColor(rgb: 0xeff3f6)
    }
    
    class func offWhiteColor() -> UIColor {
        return UIColor(rgb: 0xf1f0f2)
    }
    
    class func red() -> UIColor {
        return UIColor(rgb: 0x9c2334)
    }
    
   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
