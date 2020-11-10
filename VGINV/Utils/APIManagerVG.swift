//
//  ApiRequestHeaders.swift
//  VGINV
//
//  Created by Zohaib on 7/12/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import Alamofire

class APIManagerVG {

    static func headers() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept": Defaults.readString(key: Defaults.TOKEN)
        ]
        return headers
    }
}
