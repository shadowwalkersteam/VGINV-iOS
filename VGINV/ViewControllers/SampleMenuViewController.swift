//
// SampleMenuViewController.swift
//
// Copyright 2017 Handsome LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import InteractiveSideMenu
import CometChatPro
import SwiftUI

/**
 Menu controller is responsible for creating its content and showing/hiding menu using 'menuContainerViewController' property.
 */
class SampleMenuViewController: MenuViewController, Storyboardable {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var avatarImageViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var position: UILabel!
    private var gradientLayer = CAGradientLayer()
    private var gradientApplied: Bool = false
    
    private let downloader = ImageDownloaderNative()
    
    private var menuItems: [SideMenu]? = nil
    var groupRequest: GroupsRequest? = nil
    
    public let sideMenuItemsHMG: [SideMenu] = [
        SideMenu(title: "Home".l10n()),
        SideMenu(title: "category".l10n()),
        SideMenu(title: "Deals".l10n()),
        SideMenu(title: "My Members".l10n()),
        SideMenu(title: "HMG Members".l10n()),
        SideMenu(title: "Members Chat".l10n()),
        SideMenu(title: "Settings".l10n()),
        SideMenu(title: "VGSwitch".l10n()),
        SideMenu(title: "changePassword".l10n()),
        SideMenu(title: "profile".l10n()),
        SideMenu(title: "lgout".l10n())
    ]
    
    public let sideMenuItemsVG: [SideMenu] = [
        SideMenu(title: "Home".l10n()),
        SideMenu(title: "category".l10n()),
        SideMenu(title: "projects".l10n()),
        SideMenu(title: "My Members".l10n()),
        SideMenu(title: "VG Members".l10n()),
        SideMenu(title: "Members Chat".l10n()),
        SideMenu(title: "Settings".l10n()),
        SideMenu(title: "HMGSwitch".l10n()),
        SideMenu(title: "changePassword".l10n()),
        SideMenu(title: "profile".l10n()),
        SideMenu(title: "lgout".l10n())
    ]
    
    public let switchedSideMenuItemsHMG: [SideMenu] = [
        SideMenu(title: "Home".l10n()),
        SideMenu(title: "category".l10n()),
        SideMenu(title: "Deals".l10n()),
        SideMenu(title: "My Members".l10n()),
        SideMenu(title: "VG Members".l10n()),
        SideMenu(title: "Members Chat".l10n()),
        SideMenu(title: "Settings".l10n()),
        SideMenu(title: "VGSwitch".l10n()),
        SideMenu(title: "changePassword".l10n()),
        SideMenu(title: "profile".l10n()),
        SideMenu(title: "lgout".l10n())
    ]
    
    public let switchedSideMenuItemsVG: [SideMenu] = [
        SideMenu(title: "Home".l10n()),
        SideMenu(title: "category".l10n()),
        SideMenu(title: "projects".l10n()),
        SideMenu(title: "My Members".l10n()),
        SideMenu(title: "HMG Members".l10n()),
        SideMenu(title: "Members Chat".l10n()),
        SideMenu(title: "Settings".l10n()),
        SideMenu(title: "HMGSwitch".l10n()),
        SideMenu(title: "changePassword".l10n()),
        SideMenu(title: "profile".l10n()),
        SideMenu(title: "lgout".l10n())
    ]
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func loadView() {
        super.loadView()
//        let semantic: UISemanticContentAttribute = .forceLeftToRight
//        UIView.appearance().semanticContentAttribute = semantic
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Select the initial row
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableView.ScrollPosition.none)
        
        self.tableView.semanticContentAttribute = .forceLeftToRight
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2
        
        userName.text = Defaults.readString(key: Defaults.USER_NAME)
        position.text = Defaults.readString(key: Defaults.USER_DESIGNATION)
        
        downloader.getImage(imageUrl: Defaults.readString(key: Defaults.USER_PORIFLE_PIC), size: CGSize(width: 80,height: 80)) { (image) in
            self.avatarImageView.image = image
        }
        
        if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
            menuItems = self.switchedSideMenuItemsVG
        } else if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
            menuItems = self.switchedSideMenuItemsHMG
        } else if (UserTypes.isHMG()) {
            menuItems = self.sideMenuItemsHMG
        } else {
            menuItems = self.sideMenuItemsVG
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        avatarImageViewCenterXConstraint.constant = -(menuContainerViewController?.transitionOptions.visibleContentWidth ?? 0.0)/2
        
        if gradientLayer.superlayer != nil {
            gradientLayer.removeFromSuperlayer()
        }
        let topColor = UIColor(red: 16.0/255.0, green: 12.0/255.0, blue: 54.0/255.0, alpha: 1.0)
        let bottomColor = UIColor(red: 57.0/255.0, green: 33.0/255.0, blue: 61.0/255.0, alpha: 1.0)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    deinit{
        print()
    }
}

extension SampleMenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return menuContainerViewController?.contentViewControllers.count ?? 0
        return menuItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SampleTableCell.self), for: indexPath) as? SampleTableCell else {
            preconditionFailure("Unregistered table view cell")
        }
        
        //        cell.titleLabel.text = menuContainerViewController?.contentViewControllers[indexPath.row].title ?? "A Controller"
        cell.titleLabel.text = menuItems?[indexPath.row].title ?? "Home"
        cell.titleLabel.textAlignment = .left
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuContainerViewController = self.menuContainerViewController else {
            return
        }
        let controller = menuItems?[indexPath.row]
        print((controller?.title ?? "Home") as String)
        //        menuContainerViewController.selectContentViewController(menuContainerViewController.contentViewControllers[indexPath.row])
        menuContainerViewController.hideSideMenu()
        
        if (indexPath.row == 0) {
            print((controller?.title ?? "Home") as String)
        } else if (indexPath.row == 1) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CategoriesController")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
        }  else if (indexPath.row == 2) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProjectsDealsController")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
            //            self.present(navigationController, animated: true, completion: nil)
        } else if (indexPath.row == 3) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "allFriends")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
            //            self.present(navigationController, animated: true, completion: nil)
        } else if (indexPath.row == 4) {
            AddFriendsController.showVGUsers = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "addFriends")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
            //            self.present(navigationController, animated: true, completion: nil)
        } else if (indexPath.row == 5) {
            DashboardViewController.isMembersChat = true
            openMembersChat()
        } else if (indexPath.row == 6) {
//            let contentView = SettingsView()
//            let viewCtrl = UIHostingController(rootView: contentView)
//            menuContainerViewController.selectContentViewController2(viewCtrl)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SettingsController")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
            
            
        } else if (indexPath.row == 7) {
            if (Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
                let dict = ["hello" : "1234"] as [String : Any]
                CloudDataService.sharedInstance.toggleUser(params: dict as [String : AnyObject]?, success: { (json) in
                    if (json) as! Bool {
                        Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "hmg")
                    } else {
                        Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "vg")
                    }
                    Defaults.saveBoolena(key: Defaults.SWITCH_POPUP, value: true)
                    self.openHost()
                }, failure: { (error) in
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                    snackbar.show()
                })
            } else if (Defaults.readString(key: Defaults.USER_TYPE).contains("vg")) {
                let alert = UIAlertController(title: "HmgSwitch".l10n(), message: "PleaseContactAdminforHMGaccess".l10n(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "close".l10n(), style: UIAlertAction.Style.default, handler: { _ in
                    
                }))
                alert.addAction(UIAlertAction(title: "ClickHere".l10n(),
                                              style: UIAlertAction.Style.default,
                                              handler: {(_: UIAlertAction!) in
                                                let dict = ["hello" : "1234"] as [String : Any]
                                                CloudDataService.sharedInstance.switchToHmg(params: dict as [String : AnyObject]?, success: { (json) in
                                                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "HMGAdminwillcontactyoushortly".l10n(), duration: .long)
                                                    snackbar.show()
                                                    Defaults.saveBoolena(key: Defaults.SWITCH_POPUP, value: true)
                                                }, failure: { (error) in
                                                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                                                    snackbar.show()
                                                })
                }))
                //                self.present(alert, animated: true, completion: nil)
                menuContainerViewController.selectContentViewController2(alert)
            } else {
                if (Defaults.readBool(key: Defaults.SWITCH_POPUP)) {
                    let dict = ["hello" : "1234"] as [String : Any]
                    CloudDataService.sharedInstance.toggleUser(params: dict as [String : AnyObject]?, success: { (json) in
                        if (json) as! Bool {
                            Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "hmg")
                        } else {
                            Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "vg")
                        }
                        Defaults.saveBoolena(key: Defaults.SWITCH_POPUP, value: true)
                        self.openHost()
                    }, failure: { (error) in
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                        snackbar.show()
                    })
                } else {
                    let alert = UIAlertController(title: "switchusertitle".l10n(), message: "switchmsg".l10n(), preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "close".l10n(), style: UIAlertAction.Style.default, handler: { _ in
                        
                    }))
                    alert.addAction(UIAlertAction(title: "agree".l10n(),
                                                  style: UIAlertAction.Style.default,
                                                  handler: {(_: UIAlertAction!) in
                                                    let dict = ["hello" : "1234"] as [String : Any]
                                                    CloudDataService.sharedInstance.toggleUser(params: dict as [String : AnyObject]?, success: { (json) in
                                                        if (json) as! Bool {
                                                            Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "hmg")
                                                        } else {
                                                            Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "vg")
                                                        }
                                                        Defaults.saveBoolena(key: Defaults.SWITCH_POPUP, value: true)
                                                        self.openHost()
                                                    }, failure: { (error) in
                                                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                                                        snackbar.show()
                                                    })
                    }))
                    menuContainerViewController.selectContentViewController2(alert)
                    //                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if (indexPath.row == 8) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChangePassword")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
        } else if (indexPath.row == 9) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Profile")
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            menuContainerViewController.selectContentViewController2(navigationController)
        } else if (indexPath.row == 10) {
            if let identifier = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: identifier)
                UserDefaults.standard.synchronize()
            }
//            self.openLogin()
            DashboardViewController.openLogin = true
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    private func openMembersChat() {
        groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 50).set(joinedOnly: true).build()
        groupRequest!.fetchNext(onSuccess: { (groups) in
            print("fetchGroups onSuccess: \(groups)")
            if groups.count != 0{
                let joinedGroups = groups.filter({$0.hasJoined == true && $0.guid == UserTypes.getUserType().lowercased()})
                DispatchQueue.main.async {
                    let messageList = CometChatMessageList()
                    messageList.set(conversationWith: joinedGroups[0], type: .group)
                    messageList.hidesBottomBarWhenPushed = true
                    //                    self.menuContainerViewController!.selectContentViewController2(messageList)
                    //                    self.navigationController?.pushViewController(messageList, animated: true)
                    DashboardViewController.navigation?.pushViewController(messageList, animated: true)
                }
            }
        }) { (error) in
            print("refreshGroups error:\(String(describing: error?.errorDescription))")
        }
    }
    
    func openHost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "host")
        vc.modalPresentationStyle = .fullScreen
        //        self.present(vc, animated: true, completion: nil)
        menuContainerViewController!.selectContentViewController2(vc)
    }
    
    func openLogin() {
        navigationController?.popToRootViewController(animated: true)
        LoginController.showGif = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "login")
        vc.modalPresentationStyle = .fullScreen
        menuContainerViewController!.selectContentViewController2(vc)
        //        self.present(vc, animated: true, completion: nil)
    }
}
