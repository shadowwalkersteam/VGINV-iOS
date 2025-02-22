//
//  LoaderController.swift
//  VGINV
//
//  Created by Zohaib on 6/20/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit

/// A simple progress view
open class LoaderController {
    // MARK: - Properities
    // MARK: Class Properties
//    public static let shared = LoaderController()

    // MARK: Instance Properties
    /// The background view
    public var containerView = UIView()
    /// The bounding box for the activity indicator (`activityIndicator`)
    public var progressView = UIView()
    /// The activity indicator
    public var activityIndicator = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()

    /// The background color for `containerView`
    public var backgroundColor = UIColor.white.withAlphaComponent(0.3)
    /// The background color for the bounding box of the activity indicator (`progressView`)
    public var forgroundColor = UIColor(red: 27.0/255.0, green: 27.0/255.0, blue: 27.0/255.0, alpha: 0.7)
    /// The size of the bounding box of the activity indicator (`progressView`)
    public var size: CGSize {
        // Sanity check the value
        didSet {
            if self.size.height < 0 {
                self.size.height = 0
            }
            
            if self.size.width < 0 {
                self.size.width = 0
            }
        }
    }

    /// The style of `activityIndicator`
    public var activityStyle: UIActivityIndicatorView.Style = .whiteLarge

    private var activeConstraints = [NSLayoutConstraint]()

    // MARK: - Initializer
    public init() {
        self.size = CGSize(width: 100, height: 100)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.clipsToBounds = true
        self.progressView.layer.cornerRadius = 10
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Display
    /// Adds the progress views to the top most view
    open func showProgressView() {
        guard let topView = UIApplication.shared.keyWindow?.rootViewController?.view else {
            return
        }
        
        containerView.backgroundColor = self.backgroundColor
        progressView.backgroundColor = self.forgroundColor
        activityIndicator.style = self.activityStyle
        
//        loadingTextLabel.textColor = UIColor.white
//        loadingTextLabel.text = NSLocalizedString("pleasewait", comment: "")
//        loadingTextLabel.font = UIFont(name: "Avenir Light", size: 12)
//        loadingTextLabel.sizeToFit()
//        loadingTextLabel.center = CGPoint(x: activityIndicator.center.x, y: activityIndicator.center.y + 30)
//        activityIndicator.addSubview(loadingTextLabel)

        UIApplication.shared.keyWindow?.addSubview(containerView)
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        
        activeConstraints = [
            containerView.heightAnchor.constraint(equalTo: topView.heightAnchor),
            containerView.widthAnchor.constraint(equalTo: topView.widthAnchor),
            containerView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: topView.topAnchor),

            progressView.heightAnchor.constraint(equalToConstant: self.size.height),
            progressView.widthAnchor.constraint(equalToConstant: self.size.width),
            progressView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            progressView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            activityIndicator.heightAnchor.constraint(equalToConstant: self.size.height),
            activityIndicator.widthAnchor.constraint(equalToConstant: self.size.width),
            activityIndicator.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            
//            loadingTextLabel.heightAnchor.constraint(equalToConstant: self.size.height),
//            loadingTextLabel.widthAnchor.constraint(equalToConstant: self.size.width),
//            loadingTextLabel.centerYAnchor.constraint(equalTo: progressView.centerYAnchor),
//            loadingTextLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
//            loadingTextLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor)
        ]
        
        for constraint in activeConstraints {
            constraint.isActive = true
        }

        activityIndicator.startAnimating()
    }
    
    /// Hides the progress views from their superview
    open func hideProgressView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.containerView.removeFromSuperview()
            for constraint in self.activeConstraints {
                constraint.isActive = false
            }
            self.activeConstraints.removeAll()
        }
    }
}
