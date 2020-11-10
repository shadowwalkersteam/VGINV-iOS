//
//  ProfileController.swift
//  VGINV
//
//  Created by Zohaib on 7/2/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit

class ProfileController: UIViewController, UIScrollViewDelegate {
    var activityIndicatorView: ActivityIndicatorView!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var projects: UILabel!
    @IBOutlet weak var deals: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var bio: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButton2: UIButton!
    @IBOutlet weak var projectsTitle: UILabel!
    @IBOutlet weak var dealsTitle: UILabel!
    
    private let downloader = ImageDownloaderNative()
    
    @IBAction func editClicked2(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    @IBAction func editClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditProfileController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        
        self.scrollView.delegate = self
        
        editButton.setTitle("edit".l10n(), for: .normal)
        
        editButton.layer.cornerRadius = 24.0
        editButton.layer.borderWidth = 0
        editButton.layer.masksToBounds = true
        
        editButton2.setTitle("edit".l10n(), for: .normal)
        
        editButton2.layer.cornerRadius = 24.0
        editButton2.layer.borderWidth = 0
        editButton2.layer.masksToBounds = true
        
        if (UserTypes.isHMG()) {
            self.editButton.backgroundColor = UIColor.red
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(projectsPressed(tapGestureRecognizer:)))
        projects.isUserInteractionEnabled = true
        projects.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(dealsPressed(tapGestureRecognizer:)))
        deals.isUserInteractionEnabled = true
        deals.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(projectsPressed(tapGestureRecognizer:)))
        projectsTitle.isUserInteractionEnabled = true
        projectsTitle.addGestureRecognizer(tapGestureRecognizer3)
        
        let tapGestureRecognizer4 = UITapGestureRecognizer(target: self, action: #selector(dealsPressed(tapGestureRecognizer:)))
        dealsTitle.isUserInteractionEnabled = true
        dealsTitle.addGestureRecognizer(tapGestureRecognizer4)
        
    }
    
    @objc func projectsPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let myDict = ["userId": Defaults.readString(key: Defaults.USER_ID), "isProject" : true] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: myDict)
        
        ProfileProjectDealsController.userId = Defaults.readString(key: Defaults.USER_ID)
        ProfileProjectDealsController.isProjects = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileProjectDealsController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func dealsPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let myDict = ["userId": Defaults.readString(key: Defaults.USER_ID), "isProject" : false] as [String : Any]
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: myDict)
        
        ProfileProjectDealsController.userId = Defaults.readString(key: Defaults.USER_ID)
        ProfileProjectDealsController.isProjects = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileProjectDealsController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchUserProfile()
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
            set(title: "profile".l10n(), mode: .automatic)
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
    
    private func fetchUserProfile(){
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.getProfile(ConstantStrings.PROFILE_URL, success: { (json) in
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
            
            self.name.text = json.firstName! + " " + json.lastName!
            self.position.text = "job_title".l10n() + ": " + json.position!
            self.phone.text = json.phone!
            self.email.text = json.email!
            self.bio.text = json.description!
            self.favorites.text = json.departments[0].departments.depEn
            
            if (json.city != nil) {
             self.address.text = (json.city?.cityName)! + ", " + (json.city?.country?.countryName)!
            }
            
            var totalProjects = 0
            var totalDeals = 0
            
            for project in json.projects! {
                if (project.auth?.description ==  Defaults.readString(key: Defaults.USER_ID)) {
                    totalProjects = totalProjects + 1
                }
            }
            
            for deals in json.deals! {
                if (deals.auth?.description == Defaults.readString(key: Defaults.USER_ID)) {
                    totalDeals = totalDeals + 1
                }
            }
            
            self.deals.text = totalDeals.description
            self.projects.text = totalProjects.description
            
            self.downloader.getImage(imageUrl: json.profilePicURL, size: CGSize(width: 80,height: 80)) { (image) in
                self.profile.image = image
                //                self.profile.roundImage()
                self.profile.layer.cornerRadius = self.profile.frame.size.width/2
            }
        }, failure: { (error) in
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        })
    }
}
