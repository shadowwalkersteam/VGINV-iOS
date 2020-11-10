//
//  ViewController.swift
//  VGINV
//
//  Created by Zohaib on 6/15/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import UIKit
import SwiftyGif
import Alamofire
import SafariServices

class LoginController: UIViewController, UITextFieldDelegate {
    let logoAnimationView = LogoAnimationView()
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signup: UIButton!
    
    public static var skipScreen = false
    
    @IBAction func resetPassword(_ sender: Any) {
//        guard let url = URL(string: "https://app.vginv.com/password/reset".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
//        UIApplication.shared.open(url)
        openLink("https://app.vginv.com/password/reset")
    }
    
    @IBAction func signupPressed(_ sender: Any) {
//        guard let url = URL(string: "https://vginv.com/".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
//        UIApplication.shared.open(url)
        openLink("https://vginv.com/")
    }
    
    private func openLink(_ stringURL: String) {
        guard let url = URL(string: stringURL) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    var loader: LoaderController = LoaderController()
    
    public static var showGif = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if (LoginController.skipScreen) {
            LoginController.skipScreen = false
            openHost()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (UserDefaults.standard.string(forKey: "language") == "en" || UserDefaults.standard.string(forKey: "language") == nil) {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        } else {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
        if (LoginController.showGif) {
            view.addSubview(logoAnimationView)
            logoAnimationView.pinEdgesToSuperView()
            logoAnimationView.logoGifImageView.delegate = self
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                print("done")
                DispatchQueue.main.async {
                    self.logoAnimationView.logoGifImageView.stopAnimatingGif()
                }
            })
        }
        self.view.addBackground()
        
        userEmail.delegate = self
        userPassword.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        userEmail.layer.cornerRadius = 15.0
        userEmail.layer.borderWidth = 0
        userEmail.layer.masksToBounds = true
        
        userPassword.layer.cornerRadius = 15.0
        userPassword.layer.borderWidth = 0
        userPassword.layer.masksToBounds = true
        
        userEmail.text = ""
        userPassword.text = ""
        
        loginButton.layer.cornerRadius = 15.0
        loginButton.layer.borderWidth = 0
        loginButton.layer.masksToBounds = true
        loginButton.backgroundColor = UIColor.loginButton()
        
        signup.layer.cornerRadius = 15.0
        signup.layer.borderWidth = 0
        signup.layer.masksToBounds = true
        signup.backgroundColor = UIColor.loginButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        userEmail.text = ""
        userPassword.text = ""
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        loader.showProgressView()
        let email = userEmail.text
        let pass = userPassword.text
        
        let dict = ["email" : email!, "password" : pass!] as [String : Any]

        CloudDataService.sharedInstance.userLogin(ConstantStrings.LOGIN_URL, params: dict as [String : AnyObject]?, success: { (json) in
            // success code
            self.loader.hideProgressView()
            Defaults.saveBoolena(key: Defaults.IS_LOGGEDIN, value: true)
//            self.openDashboardController()
            self.openHost()
        }, failure: { (error) in
            //error code
            self.loader.hideProgressView()
            self.showToast(title: "Login Failed", message: "Email or Password is invalid")
            print(error)
        })
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           logoAnimationView.logoGifImageView.startAnimatingGif()
       }
    
    func openDashboardController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DashboardController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.title = "Home"
        navigationController.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            
            navBarAppearance.titleTextAttributes = [ .foregroundColor:  UIColor.label,.font: UIFont (name: "SFProDisplay-Bold", size: 20) as Any]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont(name: "SFProDisplay-Bold", size: 30) as Any]
            navBarAppearance.shadowColor = .clear
            navBarAppearance.backgroundColor = .systemBackground
            navigationController.navigationBar.standardAppearance = navBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
            self.navigationController?.navigationBar.isTranslucent = false
        }
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func openHost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "host")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension LoginController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
        if (Defaults.readBool(key: Defaults.IS_LOGGEDIN)) {
//            openDashboardController()
            openHost()
        }
    }
}
