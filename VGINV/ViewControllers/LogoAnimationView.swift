//
//  LogoAnimationView.swift
//  VGINV
//
//  Created by Zohaib on 6/15/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import SwiftyGif

class LogoAnimationView: UIView {
    
    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "splash_gif.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 1)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
//        backgroundColor = UIColor(white: 246.0 / 255.0, alpha: 1)
        backgroundColor = UIColor(rgb: 0xbfc4c8)
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalToConstant: 580).isActive = true
        logoGifImageView.heightAnchor.constraint(equalToConstant: 408).isActive = true
    }
}
