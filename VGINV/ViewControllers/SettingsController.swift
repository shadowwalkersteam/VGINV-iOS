//
//  SettingsController.swift
//  VGINV
//
//  Created by Zohaib on 8/18/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import Spring
import L10n_swift

class SettingsController: UIViewController {
    @IBOutlet weak var editProfileView: DesignableView!
    @IBOutlet weak var changePasswordView: DesignableView!
    @IBOutlet weak var changeLanguageView: DesignableView!
    @IBOutlet weak var appVersion: UILabel!
    
     private var items: [L10n] = L10n.supportedLanguages.map { L10n(language: $0) }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.dashboardBackground()
        let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        appVersion.text = "App Version: " + text
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfileButtonPressed(tapGestureRecognizer:)))
        editProfileView.isUserInteractionEnabled = true
        editProfileView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(passwordButtonPressed(tapGestureRecognizer:)))
        changePasswordView.isUserInteractionEnabled = true
        changePasswordView.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(languageButtonPressed(tapGestureRecognizer:)))
        changeLanguageView.isUserInteractionEnabled = true
        changeLanguageView.addGestureRecognizer(tapGestureRecognizer3)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.onLanguageChanged), name: .L10nLanguageChanged, object: nil
        )
    }
    
    @IBAction
    private func onLanguageChanged() {
//        let semantic: UISemanticContentAttribute = .forceRightToLeft
//        UIView.appearance().semanticContentAttribute = semantic
        
        UserDefaults.standard.set(L10n.shared.language, forKey: "language")
        
        self.navigationController?.setViewControllers(
            self.navigationController?.viewControllers.map {
                if let storyboard = $0.storyboard {
                    return storyboard.instantiateInitialViewController()!
                }
                return $0
            } ?? [],
            animated: false
        )
    }
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar(){
        if navigationController != nil{
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont (name: "SFProDisplay-Regular", size: 20) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont(name: "SFProDisplay-Bold", size: 35) as Any]
                navBarAppearance.shadowColor = .clear
                navBarAppearance.backgroundColor = UIColor.offWhiteColor()
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            self.addCreateGroup()
            set(title: "Settings".l10n(), mode: .automatic)
        }
    }
    
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = title
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }
    }
    
    private func addCreateGroup(){
        let backButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal) // Image can be downloaded from here below link
        backButton.setTitle("Back".l10n(), for: .normal)
        backButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func backButtonPressed(){
        navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editProfileButtonPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func passwordButtonPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangePassword")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func languageButtonPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let alert = UIAlertController(title: "Change_Language".l10n(), message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "English", style: .default, handler: { (_) in
            L10n.shared.language = self.items[1].language
            
            
//            LanguageManager.shared.setLanguage(language: .en,
//                                               viewControllerFactory: { title -> UIViewController in
//              let storyboard = UIStoryboard(name: "Main", bundle: nil)
//              return storyboard.instantiateInitialViewController()!
//            }) { view in
//              view.transform = CGAffineTransform(scaleX: 2, y: 2)
//              view.alpha = 0
//            }
        }))

        alert.addAction(UIAlertAction(title: "Arabic", style: .default, handler: { (_) in
            L10n.shared.language = self.items[0].language
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            storyboard.instantiateInitialViewController()
            
//            LanguageManager.shared.setLanguage(language: .ar,
//                                               viewControllerFactory: { title -> UIViewController in
//              let storyboard = UIStoryboard(name: "Main", bundle: nil)
//              return storyboard.instantiateInitialViewController()!
//            }) { view in
//              view.transform = CGAffineTransform(scaleX: 2, y: 2)
//              view.alpha = 0
//            }
        }))

        alert.addAction(UIAlertAction(title: "close".l10n(), style: .cancel, handler: { (_) in

        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
}
