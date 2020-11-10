//
//  AddFriendsController.swift
//  VGINV
//
//  Created by Zohaib on 7/23/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit

class FriendsCustomViewCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var section: UILabel!
    @IBOutlet weak var addFriendsButton: UIImageView!
    
    var identifier: String?
    var imageSize: CGSize = CGSize(width: 80, height: 80)
    
    func update(image: UIImage?, matchingIdentifier: String?) {
        guard identifier == matchingIdentifier else { return }
        profilePic.image = image
        profilePic.roundImage()
    }
}

class AddFriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicatorView: ActivityIndicatorView!
    private var allUsers: [AllUsersData] = []
    private let downloader = ImageDownloaderNative()
    private var userType = Defaults.readString(key: Defaults.USER_TYPE)
    public static var showVGUsers = false
    
    override public func loadView() {
        super.loadView()
        tableView.dataSource = self
        tableView.delegate = self
        self.setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        fetchAllUsers()
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
            set(title: "AddFriends".l10n(), mode: .automatic)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendscell", for: indexPath) as! FriendsCustomViewCell
        cell.backgroundColor = UIColor.dashboardBackground()
        let data = allUsers[indexPath.row]
        //        if (UserTypes.isHMG() && data.type!.contains("hmg")) {
        //            let userID = data.id?.description
        //            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendRequest(tapGestureRecognizer:)))
        //            tapGestureRecognizer.numberOfTapsRequired = 1
        //            cell.addFriendsButton?.isUserInteractionEnabled = true
        //            cell.addFriendsButton?.addGestureRecognizer(tapGestureRecognizer)
        //            cell.name.text = data.firstName! + " " + data.lastName!
        //            cell.section.text = data.position!
        //            cell.identifier = userID
        //            downloader.getImage(imageUrl: data.userImage, size: cell.imageSize) { (image) in
        //                cell.update(image: image, matchingIdentifier: userID)
        //            }
        //
        //        } else if (!UserTypes.isHMG() && data.type!.contains("vg")) {
        //            let userID = data.id?.description
        //            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendRequest(tapGestureRecognizer:)))
        //            tapGestureRecognizer.numberOfTapsRequired = 1
        //            cell.addFriendsButton?.isUserInteractionEnabled = true
        //            cell.addFriendsButton?.addGestureRecognizer(tapGestureRecognizer)
        //            cell.name.text = data.firstName! + " " + data.lastName!
        //            cell.section.text = data.position!
        //            cell.identifier = userID
        //            downloader.getImage(imageUrl: data.userImage, size: cell.imageSize) { (image) in
        //                cell.update(image: image, matchingIdentifier: userID)
        //            }
        //        }
        let userID = data.id?.description
        let tapGestureRecognizer = MyTapGesture(target: self, action: #selector(sendRequest(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.identifer = userID!
        cell.addFriendsButton?.isUserInteractionEnabled = true
        cell.addFriendsButton?.addGestureRecognizer(tapGestureRecognizer)
        cell.name.text = data.firstName! + " " + data.lastName!
        cell.section.text = data.position!
        cell.identifier = userID
        downloader.getImage(imageUrl: data.userImage, size: cell.imageSize) { (image) in
            cell.update(image: image, matchingIdentifier: userID)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = allUsers[indexPath.row]
        print(data.id!)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FriendsProfile")
        FriendsProfileController.userID = data.id!.description
        FriendsProfileController.isFriend = false
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func sendRequest(_ sender: MyTapGesture) {
        let parameters = [
            "friendId": sender.identifer,
            "created_at": Date().description
            ] as [String : Any]
        
        CloudDataService.sharedInstance.sendFriendRequest(params: parameters as [String : AnyObject]?, success: { (json) in
            // success code
            let imgView = sender.view as! UIImageView
            imgView.image = UIImage(named: "check")
            self.sendOneSignalNotification(userID: sender.identifer, userName: Defaults.readString(key: Defaults.USER_NAME))
        }, failure: { (error) in
            //error code
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
        })
    }
    
    private func sendOneSignalNotification(userID : String, userName : String) {
        let notificationContent = [
            "include_external_user_ids": [userID],
            "contents": ["en": "You have a new friend request from " + userName + "."],
            "headings": ["en": "Friend Request"],
            "data": ["foo": "bar"],
            "android_channel_id": "163157c3-fe29-49c0-b9bf-f713dc59eff4",
            "app_id": "af0bb11e-f674-47a8-8718-bc1c78c36019"
        ] as [String : Any]

        CloudDataService.sharedInstance.sendOneSignalNotification(ConstantStrings.ONESIGNAL, params: notificationContent as [String : AnyObject]?, success: { (json) in

        }, failure: { (error) in
            print(error)
        })
    }
    
    private func fetchAllUsers(){
        var parameters = [:] as [String : Any]
        if (AddFriendsController.showVGUsers) {
            parameters = [
                "type": "vg"
                ] as [String : Any]
        } else {
            parameters = [
                "type": userType
                ] as [String : Any]
        }
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.getAllUsers(url: ConstantStrings.ALL_USERS, params: parameters, success: { (json) in
            DispatchQueue.main.async {
                if (json.users.count > 0) {
                    self.allUsers = json.users
                    self.tableView.reloadData()
                } else {
                    self.tableView?.setEmptyMessage("no_members_to_add".l10n())
                }
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
            }
        })
    }
    
    class MyTapGesture: UITapGestureRecognizer {
        var identifer = String()
    }
}
