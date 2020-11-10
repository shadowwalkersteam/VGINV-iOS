//
//  FriendsController.swift
//  VGINV
//
//  Created by Zohaib on 7/26/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro


class FriendsViewCell: UITableViewCell {
    var identifier: String?
    var imageSize: CGSize = CGSize(width: 80, height: 80)
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var message: UIImageView!
    @IBOutlet weak var unfriend: UIImageView!
    
    func update(image: UIImage?, matchingIdentifier: String?) {
        guard identifier == matchingIdentifier else { return }
        profilePic.image = image
        profilePic.roundImage()
    }
}

class FriendsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicatorView: ActivityIndicatorView!
    private var allUsers: [AllUsersData] = []
    private let downloader = ImageDownloaderNative()
    
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
            set(title: "Friends".l10n(), mode: .automatic)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "allfriendscell", for: indexPath) as! FriendsViewCell
        cell.backgroundColor = UIColor.dashboardBackground()
        let data = allUsers[indexPath.row]
        if (data.type!.contains("vg")) {
            cell.type.isHidden = false
        }
        let userID = data.id?.description
        let tapGestureRecognizer = UnFirendTapGesture(target: self, action: #selector(unFriendUser(_:)))
        tapGestureRecognizer.identifer = userID!
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.currentUser = data
        cell.unfriend?.isUserInteractionEnabled = true
        cell.unfriend?.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = ChatFirendTapGesture(target: self, action: #selector(openChat(_:)))
        tapGestureRecognizer2.numberOfTapsRequired = 1
        tapGestureRecognizer2.identifer = userID!
        cell.message?.isUserInteractionEnabled = true
        cell.message?.addGestureRecognizer(tapGestureRecognizer2)
        
        cell.userName.text = data.firstName! + " " + data.lastName!
        cell.position.text = data.position!
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
        FriendsProfileController.isFriend = true
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    private func fetchAllUsers() {
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.getAllFriends(success: { (json) in
            DispatchQueue.main.async {
                if (json.users.count > 0) {
                    self.allUsers = json.users
                    self.tableView.reloadData()
                } else {
                    self.tableView?.setEmptyMessage("no_friends_added".l10n())
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
    
    @objc private func unFriendUser(_ sender: UnFirendTapGesture) {
        
        let alert = UIAlertController(title: "UnFriend".l10n(), message: "UnFriendMessage".l10n(), preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "no".l10n(), style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "yes".l10n(),
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        let parameters = [
                                            "friendId": sender.identifer
                                            ] as [String : Any]
                                        
                                        CloudDataService.sharedInstance.unFriendUser(params: parameters as [String : AnyObject], success: { (json) in
                                            if let index = self.allUsers.firstIndex(of: sender.currentUser!) {
                                                self.allUsers.remove(at: index)
                                                self.tableView.reloadData()
                                            }
                                        }, failure: { (error) in
                                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError", duration: .short)
                                            snackbar.show()
                                        })
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func openChat(_ sender: ChatFirendTapGesture) {
        CometChat.getUser(UID: sender.identifer, onSuccess: { (user) in
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
    }
}

class ChatFirendTapGesture: UITapGestureRecognizer {
    var identifer = String()
    
}

class UnFirendTapGesture: UITapGestureRecognizer {
    var identifer = String()
    var currentUser: AllUsersData? = nil
}
