//
//  ChangePassword.swift
//  VGINV
//
//  Created by Zohaib on 8/15/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit

class ChangePassword: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var vgView: UIView!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var confirmPassword: UITextField!
    
    var activityIndicatorView: ActivityIndicatorView!
    private let downloader = ImageDownloaderNative()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        
        changePassword.layer.cornerRadius = 24.0
        changePassword.layer.borderWidth = 0
        changePassword.layer.masksToBounds = true
        
        if (UserTypes.isHMG()) {
            changePassword.backgroundColor = UIColor.red
        }
        self.hideKeyboardWhenTappedAround()
        vgView.round(corners: [.bottomLeft], radius: 60)
        
        confirmPassword.delegate = self
        newPassword.delegate = self
        oldPassword.delegate = self
                
//        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
//                                               name: UIResponder.keyboardDidShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
//                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    @objc func keyboardDidShow(notification: NSNotification) {
//        let info = notification.userInfo
//        let keyBoardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//        self.view.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
//        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
//    }
//
//    @objc func keyboardDidHide(notification: NSNotification) {
//        scrollView.contentInset = UIEdgeInsets.zero
//        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
//    }
    
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
            set(title: "changePassword".l10n(), mode: .automatic)
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
    @IBAction func changePasswordClicked(_ sender: Any) {
        let oldPass = oldPassword.text?.description
        let newPass = newPassword.text?.description
        let confirmPass = confirmPassword.text?.description
        
        if (oldPass!.isEmpty || newPass!.isEmpty || confirmPass!.isEmpty) {
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "fieldRequired".l10n(), duration: .short)
            snackbar.show()
            return
        }
        
        if (newPass != confirmPass) {
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "passwordMatchError".l10n(), duration: .short)
            snackbar.show()
            return
        }
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        let dict = ["currentPassword" : oldPass ?? "", "newPassword": newPass ?? ""] as [String : Any]
        CloudDataService.sharedInstance.changePassword(params: dict as [String : AnyObject]?, success: { (json) in
            if (json) as! Bool {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "passwordChangeSuccesss".l10n(), duration: .short)
                snackbar.show()
                if let identifier = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: identifier)
                    UserDefaults.standard.synchronize()
                }
                DashboardViewController.openLogin = true
                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
//                self.openLogin()
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "passwordChangeError".l10n(), duration: .short)
                snackbar.show()
            }
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "passwordChangeError".l10n(), duration: .short)
            snackbar.show()
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func openLogin() {
        navigationController?.popToRootViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        LoginController.showGif = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
