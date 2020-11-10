//
//  FriendsProfileController.swift
//  VGINV
//
//  Created by Zohaib on 8/2/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro

class FriendsProfileController: UIViewController {
    private let downloader = ImageDownloaderNative()
    var activityIndicatorView: ActivityIndicatorView!
    public static var userID = ""
    public static var isFriend = false
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var projects: UILabel!
    @IBOutlet weak var deals: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var bio: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var sendMessage: UIButton!
    @IBOutlet weak var projectsTitle: UILabel!
    @IBOutlet weak var dealsTitle: UILabel!
    
    
    @IBAction func sendMessage(_ sender: Any) {
        if (FriendsProfileController.isFriend) {
            CometChat.getUser(UID: FriendsProfileController.userID, onSuccess: { (user) in
                DispatchQueue.main.async {
                    print("User: " + user!.stringValue())
                    let  messageList = CometChatMessageList()
                    messageList.set(conversationWith: user!, type: .user)
                    messageList.hidesBottomBarWhenPushed = true
                    self.navigationController!.pushViewController(messageList, animated: true)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    print("User fetching failed with error: " + error!.errorDescription);
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "User doesn't exist in CometChat", duration: .short)
                    snackbar.show()
                }
            }
        } else {
            let parameters = [
                "friendId": FriendsProfileController.userID,
                "created_at": Date().description
                ] as [String : Any]
            
            CloudDataService.sharedInstance.sendFriendRequest(params: parameters as [String : AnyObject]?, success: { (json) in
                // success code
                FriendsProfileController.self.isFriend = true
                self.sendMessage.setTitle("SEND_MESSAGE".l10n(), for: .normal)
            }, failure: { (error) in
                //error code
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                snackbar.show()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        
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
        
        sendMessage.layer.cornerRadius = 24.0
        sendMessage.layer.borderWidth = 0
        sendMessage.layer.masksToBounds = true
        
        if (FriendsProfileController.isFriend) {
            sendMessage.setTitle("SEND_MESSAGE".l10n(), for: .normal)
        } else {
            sendMessage.setTitle("add_member".l10n(), for: .normal)
        }
        
        fetchUserProfile()
    }
    
    @objc func projectsPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let myDict = ["userId": Defaults.readString(key: Defaults.USER_ID), "isProject" : true] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: myDict)
        
        ProfileProjectDealsController.userId = FriendsProfileController.userID
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
        
        ProfileProjectDealsController.userId = FriendsProfileController.userID
        ProfileProjectDealsController.isProjects = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileProjectDealsController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
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
        
        CloudDataService.sharedInstance.getProfile(ConstantStrings.FRIENDS_PROFILE + FriendsProfileController.userID, success: { (json) in
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
            
            self.name.text = json.firstName! + " " + json.lastName!
            self.position.text = "job_title".l10n() + ": " + json.position!
            self.phone.text = json.phone!
            self.email.text = json.email!
            self.bio.text = json.description!
            do {
                if (json.departments.count > 0) {
                    self.department.text = json.departments[0].departments.depEn
                } else{
                    self.department.text = ""
                }
            } catch {
                self.department.text = ""
            }
            
            if (json.city?.cityName != nil && json.city?.country?.countryName != nil) {
                self.address.text = (json.city?.cityName)! + ", " + (json.city?.country?.countryName)!
            }
            
            var totalProjects = 0
            var totalDeals = 0
            
            for project in json.projects! {
                if (project.auth?.description ==  FriendsProfileController.userID) {
                    totalProjects = totalProjects + 1
                }
            }
            
            for deals in json.deals! {
                if (deals.auth?.description == FriendsProfileController.userID) {
                    totalDeals = totalDeals + 1
                }
            }
            
            self.deals.text = totalDeals.description
            self.projects.text = totalProjects.description
            
            self.downloader.getImage(imageUrl: json.profilePicURL, size: CGSize(width: 80,height: 80)) { (image) in
                self.profilePic.image = image
//                self.profilePic.roundImage()
                self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
            }
        }, failure: { (error) in
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        })
    }
}
