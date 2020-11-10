//
//  NotificationsController.swift
//  VGINV
//
//  Created by Zohaib on 7/27/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit

class NotificationsViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var accept: UIImageView!
    @IBOutlet weak var reject: UIImageView!
    @IBOutlet weak var desc: UILabel!
    
    var identifier: String?
}


class NotificationsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicatorView: ActivityIndicatorView!
    private var allNotifications: [AllNotifications] = []
    
    override public func loadView() {
        super.loadView()
        tableView.dataSource = self
        tableView.delegate = self
        self.setupNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        fetchAllNotifications()
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
            set(title: "notifications".l10n(), mode: .automatic)
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
        return allNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationsCell", for: indexPath) as! NotificationsViewCell
        cell.backgroundColor = UIColor.dashboardBackground()
        let data = allNotifications[indexPath.row]
        let userID = data.id?.description
        var senderID = ""
        if (data.type!.contains("addFriend")) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data.notificationData!.data(using: .utf8)!, options: []) as? [String: Any] {
                    if let res = json["sender_name"] as? String {
                        let senderId = json["sender"] as? Int
                        cell.title.text = "friendrequest".l10n()
                        cell.desc.text = res + " " + "friendRequestDetails".l10n()
                        senderID = senderId!.description
                    }
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
            let tapGestureRecognizer = AcceptRejectTapGesture(target: self, action: #selector(acceptReq(_:)))
            tapGestureRecognizer.identifer = userID!
            tapGestureRecognizer.numberOfTapsRequired = 1
            tapGestureRecognizer.currentNotification = data
            tapGestureRecognizer.senderID = senderID
            cell.accept?.isUserInteractionEnabled = true
            cell.accept?.addGestureRecognizer(tapGestureRecognizer)
            
            let tapGestureRecognizer2 = AcceptRejectTapGesture(target: self, action: #selector(rejectReq(_:)))
            tapGestureRecognizer2.numberOfTapsRequired = 1
            tapGestureRecognizer2.identifer = userID!
            tapGestureRecognizer2.currentNotification = data
            tapGestureRecognizer2.senderID = senderID
            cell.reject?.isUserInteractionEnabled = true
            cell.reject?.addGestureRecognizer(tapGestureRecognizer2)

            cell.identifier = userID
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func fetchAllNotifications() {
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.getNotifications(success: { (json) in
            if (json.notifications.count > 0) {
                self.allNotifications = json.notifications
                self.tableView.reloadData()
            } else {
                self.tableView.setEmptyMessage("no_new_notifications".l10n())
            }
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        }, failure: { (error) in
            
        })
    }
    
    @objc private func acceptReq(_ sender: AcceptRejectTapGesture) {
        var url = ConstantStrings.ACCEPT_REQUEST + (sender.currentNotification?.id)!
        url = url + "/" + sender.senderID + "/" + "confirm"
        
        CloudDataService.sharedInstance.acceptRequest(url: url, success: { (json) in
            if let index = self.allNotifications.firstIndex(of: sender.currentNotification!) {
                self.allNotifications.remove(at: index)
                self.tableView.reloadData()
            }
            self.sendOneSignalNotification(userID: (sender.currentNotification?.id)!, userName: Defaults.readString(key: Defaults.USER_NAME))
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
        })
    }
    
    
    private func sendOneSignalNotification(userID : String, userName : String) {
        let notificationContent = [
            "include_external_user_ids": [userID],
            "contents": ["en": userName + " has accepted your friend request."],
            "headings": ["en": "Friend Request Accepted"],
            "data": ["foo": "bar"],
            "android_channel_id": "163157c3-fe29-49c0-b9bf-f713dc59eff4",
            "app_id": "af0bb11e-f674-47a8-8718-bc1c78c36019"
        ] as [String : Any]

        CloudDataService.sharedInstance.sendOneSignalNotification(ConstantStrings.ONESIGNAL, params: notificationContent as [String : AnyObject]?, success: { (json) in

        }, failure: { (error) in
            print(error)
        })
    }
    
    @objc private func rejectReq(_ sender: AcceptRejectTapGesture) {
        var url = ConstantStrings.ACCEPT_REQUEST + (sender.currentNotification?.id)!
        url = url + "/" + sender.senderID + "/" + "cancel"
        
        CloudDataService.sharedInstance.acceptRequest(url: url, success: { (json) in
            if let index = self.allNotifications.firstIndex(of: sender.currentNotification!) {
                self.allNotifications.remove(at: index)
                self.tableView.reloadData()
            }
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
        })
    }
    
    class AcceptRejectTapGesture: UITapGestureRecognizer {
        var identifer = String()
        var senderID = String()
        var currentNotification: AllNotifications? = nil
    }
}
