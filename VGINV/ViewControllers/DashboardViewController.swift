//
//  DashboardViewController.swift
//  VGINV
//
//  Created by Zohaib on 6/21/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro
import InteractiveSideMenu
import Firebase
import OneSignal


class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SideMenuItemContent, Storyboardable {
    
    @IBOutlet weak var hmgWarningConstraint: NSLayoutConstraint!
    @IBOutlet weak var hmgWarningView: UIView!
    @IBOutlet weak var hmgWarningLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var projectsCollectionView: UICollectionView!
    @IBOutlet weak var addProjectButton: UIButton!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var seeMore: UIButton!
    @IBOutlet weak var newCollectionView: UICollectionView!
    @IBOutlet weak var projectHeading: UILabel!
    
    @IBAction func addNewProject(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddProject")
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    @IBAction func seeMoreClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProjectsDealsController")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    var activityIndicatorView: ActivityIndicatorView!
    
    private var dealsItems: [DealsCatalog] = []
    private var projectItems: [ProjectsCatalog] = []
    private var newsItems: [NewsDetails] = []
    private let downloader = ImageDownloaderNative()
    public static var isMembersChat = false
    var groupRequest: GroupsRequest? = nil
    private let gridReuseIdentifier = "GridCell"
    private var movies: [Movie]? = nil
    private var layoutOption: LayoutOption = .list {
        didSet {
            setupLayout(with: view.bounds.size)
        }
    }
    static var countriesList = [Int:String]()
    static var citiesList = [Int:Any]()
    static var departments = [Int:Any]()
    
    static var openLogin = false
    
    public static var navigation: UINavigationController? = nil
    
    public let dummyMovies: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "VGSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "Deals".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    public let dummyMoviesVg: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "HmgSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "projects".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    public let switchedDummyMoviesVG: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "HmgSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "projects".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    public let switchedDummyMovies: [Movie] = [
        Movie(title: "notifications".l10n(), description: "", posterImage: UIImage(named: "notifications3")),
        Movie(title: "category".l10n(), description: "", posterImage: UIImage(named: "categories3")),
        Movie(title: "My Members".l10n(), description: "", posterImage: UIImage(named: "members3")),
        Movie(title: "HMG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "Members Chat".l10n(), description: "", posterImage: UIImage(named: "group_chat3")),
        Movie(title: "Settings".l10n(), description: "", posterImage: UIImage(named: "settings3")),
        Movie(title: "VGSwitch".l10n(), description: "", posterImage: UIImage(named: "switch3")),
        Movie(title: "Chats".l10n(), description: "", posterImage: UIImage(named: "messages3")),
        Movie(title: "Deals".l10n(), description: "", posterImage: UIImage(named: "deal3")),
        Movie(title: "Group Chat".l10n(), description: "", posterImage: UIImage(named: "rooms")),
        Movie(title: "VG Members".l10n(), description: "", posterImage: UIImage(named: "add_members3")),
        Movie(title: "profile".l10n(), description: "", posterImage: UIImage(named: "profile_new_icon"))
    ]
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        self.setupNavigationBar()
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
    
    private func setupNavigationBar(){
        if navigationController != nil{
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont (name: "SFProDisplay-Regular", size: 20) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont(name: "SFProDisplay-Bold", size: 35) as Any]
                navBarAppearance.shadowColor = .clear
                navBarAppearance.backgroundColor = UIColor.dashboardBackground()
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            DashboardViewController.navigation = navigationController
            set(title: "Home".l10n(), mode: .automatic)
            self.setUpMenuButton()
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
    
    func setUpMenuButton(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"menu"), for: .normal)
        menuBtn.addTarget(self, action: #selector(sideMenuPressed), for: UIControl.Event.touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
      
      @objc func sideMenuPressed(){
          print("side menu pressed")
        showSideMenu()
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.projectsCollectionView) {
            do {
                if (Defaults.readString(key: Defaults.USER_TYPE) != nil) {
                    if (UserTypes.isHMG()) {
                        return dealsItems.count
                    } else {
                        return projectItems.count
                    }
                } else {
                    return 0
                }
            }  catch {
                print("Couldn't load HomeSoundtrack file")
            }
        } else  if(collectionView == self.newCollectionView) {
            return newsItems.count
        }
        else {
            return movies!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.projectsCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "The Washington Post", for: indexPath) as! NewsCell
            do {
                if (Defaults.readString(key: Defaults.USER_TYPE) != nil) {
                    if (UserTypes.isHMG()) {
                        let article = dealsItems[indexPath.row]
                        let identifier = article.id?.description
                        cell.configureDeals(article)
                        
                        cell.updateWithURL(url: URL(string: article.dealsImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), matchingIdentifier: identifier, size: cell.imageSizeUnwrapped)
//                        downloader.getImage(imageUrl: article.dealsImage, size: cell.imageSizeUnwrapped) { (image) in
//                            cell.update(image: image, matchingIdentifier: identifier)
//                        }
                    } else {
                        let article = projectItems[indexPath.row]
                        let identifier = article.id?.description
                        cell.configureProjects(article)
                        
                        cell.updateWithURL(url: URL(string: article.projectsImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), matchingIdentifier: identifier, size: cell.imageSizeUnwrapped)
//                        downloader.getImage(imageUrl: article.projectsImage, size: cell.imageSizeUnwrapped) { (image) in
//                            cell.update(image: image, matchingIdentifier: identifier)
//                        }
                    }
                }
            }  catch {
                print("Couldn't load HomeSoundtrack file")
                
            }
            
            return cell
        } else if(collectionView == self.newCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "The Washington Post", for: indexPath) as! NewsCell
            let article = newsItems[indexPath.row]
            let identifier = article.id?.description
            cell.configureNews(article)
            
            cell.updateWithURL(url: URL(string: article.newsImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), matchingIdentifier: identifier, size: cell.imageSizeUnwrapped)
//            downloader.getImage(imageUrl: article.newsImage, size: cell.imageSizeUnwrapped) { (image) in
//                cell.update(image: image, matchingIdentifier: identifier)
//
//            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridReuseIdentifier, for: indexPath) as! MovieLayoutGridCollectionViewCell
            let movie = movies![indexPath.item]
            cell.setup(with: movie)
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if(collectionView == self.projectsCollectionView) {
            if (UserTypes.isHMG()) {
                let data = dealsItems[indexPath.row]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProjectsDetails")
                ProjectDetailsController.deals = data
                ProjectDetailsController.projects = nil
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            } else {
                let data = projectItems[indexPath.row]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProjectsDetails")
                ProjectDetailsController.projects = data
                ProjectDetailsController.deals = nil
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            
        } else  if(collectionView == self.newCollectionView) {
            let data = newsItems[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "NewsController")
            NewsDetailsController.title = data.title!
            NewsDetailsController.details = data.content!
            NewsDetailsController.image = data.newsImage
            let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
        else {
            if (indexPath.row == 0) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "notifications")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            else if (indexPath.row == 1) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CategoriesController")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            else if (indexPath.row == 2) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "allFriends")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            } else if (indexPath.row == 3) {
                AddFriendsController.showVGUsers = false
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "addFriends")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            else if (indexPath.row == 11) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Profile")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            } else if (indexPath.row == 4) {
                DashboardViewController.isMembersChat = true
                openMembersChat()
            } else if (indexPath.row == 5) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SettingsController")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            else if (indexPath.row == 6) {
                if (Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
                    let dict = ["hello" : "1234"] as [String : Any]
                    CloudDataService.sharedInstance.toggleUser(params: dict as [String : AnyObject]?, success: { (json) in
                        if (json) as! Bool {
                            Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "hmg")
                        } else {
                            Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "vg")
                        }
                        Defaults.saveBoolena(key: Defaults.SWITCH_POPUP, value: true)
                        self.reOpenDashboardController()
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
                    self.present(alert, animated: true, completion: nil)
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
                            self.reOpenDashboardController()
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
                                                            self.reOpenDashboardController()
                                                        }, failure: { (error) in
                                                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                                                            snackbar.show()
                                                        })
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else if (indexPath.row == 7) {
                let messages = CometChatConversationList()
                let navigationController = UINavigationController(rootViewController: messages)
                navigationController.modalPresentationStyle = .fullScreen
                messages.set(title: "Chats", mode: .automatic)
                self.present(navigationController, animated: true, completion: nil)
            }
            else if (indexPath.row == 8) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ProjectsDealsController")
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
            else if (indexPath.row == 9) {
                DashboardViewController.isMembersChat = false
                let groupList = CometChatGroupList()
                let navigationController = UINavigationController(rootViewController: groupList)
                navigationController.modalPresentationStyle = .fullScreen
                groupList.set(title: "Group Chats", mode: .automatic)
                self.present(navigationController, animated: true, completion: nil)
            } else if (indexPath.row == 10) {
                if (Defaults.readString(key: Defaults.USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
                    AddFriendsController.showVGUsers = true
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "addFriends")
                    let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true, completion: nil)
                } else {
                    self.showToast(title: "members_notification".l10n(), message: "hmg_members_message".l10n())
                }
            }
        }
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
                    self.navigationController?.pushViewController(messageList, animated: true)
                }
            }
        }) { (error) in
            print("refreshGroups error:\(String(describing: error?.errorDescription))")
        }
    }
    
    @objc func switchBackToHMG(_ sender: UITapGestureRecognizer) {
        if (Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
            let dict = ["hello" : "1234"] as [String : Any]
            CloudDataService.sharedInstance.toggleUser(params: dict as [String : AnyObject]?, success: { (json) in
                if (json) as! Bool {
                    Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "hmg")
                } else {
                    Defaults.saveString(key: Defaults.TOGGLER_USER_TYPE, value: "vg")
                }
                Defaults.saveBoolena(key: Defaults.SWITCH_POPUP, value: true)
                self.reOpenDashboardController()
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
            self.present(alert, animated: true, completion: nil)
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
                    self.reOpenDashboardController()
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
                                                    self.reOpenDashboardController()
                                                }, failure: { (error) in
                                                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
                                                    snackbar.show()
                                                })
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        
        if (Defaults.readString(key: Defaults.USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
            movies = self.dummyMovies
        } else {
            movies = self.dummyMoviesVg
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(switchBackToHMG(_:)))
        self.hmgWarningView.addGestureRecognizer(tapGestureRecognizer)
        
        addProjectButton.layer.cornerRadius = 24.0
        addProjectButton.layer.borderWidth = 0
        addProjectButton.layer.masksToBounds = true
        
        if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
            hmgWarningLabel.text = "switchback_hmg".l10n()
            hmgWarningView.isHidden = false
            self.hmgWarningConstraint.constant = 32
            self.movies = self.switchedDummyMoviesVG
            seeMore.setTitle("load_more".l10n(), for: .normal)
            self.collectionView.reloadData()
        } else if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
            seeMore.backgroundColor = UIColor.red
            addProjectButton.backgroundColor = UIColor.red
            self.movies = self.switchedDummyMovies
            seeMore.setTitle("load_more_deals".l10n(), for: .normal)
            self.collectionView.reloadData()
        } else if (UserTypes.isHMG()) {
            seeMore.backgroundColor = UIColor.red
            addProjectButton.backgroundColor = UIColor.red
            seeMore.setTitle("load_more_deals".l10n(), for: .normal)
            addProjectButton.setTitle("AddNewDeal".l10n(), for: .normal)
            projectHeading.text = "Deals".l10n()
        } else {
            addProjectButton.setTitle("AddNewProject".l10n(), for: .normal)
            seeMore.setTitle("load_more".l10n(), for: .normal)
            projectHeading.text = "projects".l10n()
        }
        
        seeMore.layer.cornerRadius = 24.0
        seeMore.layer.borderWidth = 0
        seeMore.layer.masksToBounds = true
        
        projectsCollectionView.backgroundColor = UIColor.dashboardBackground()
        
        //        let layout = UICollectionViewFlowLayout()
        //        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //        layout.itemSize = CGSize(width: 90, height: 90)
        //        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout);
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.dashboardBackground()
        
        newCollectionView.dataSource = self
        newCollectionView.delegate = self
        newCollectionView.backgroundColor = UIColor.dashboardBackground()
        
        scroller.backgroundColor = UIColor.dashboardBackground()
        
        fetchUserProfile()
        
        setupCollectionView()
        setupLayout(with: view.bounds.size)
        
        fetchCountriesAndCities()
        //        config()
        //        loadData("general")
        
//         NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "notificationName"), object: nil)
    }
    
//    @objc func showSpinningWheel(_ notification: NSNotification) {
//        print("hello")
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (DashboardViewController.openLogin) {
            openLogin()
            DashboardViewController.openLogin = false
            return
        }
        fetchUserProfileAgain()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupLayout(with: size)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupLayout(with: view.bounds.size)
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "MovieLayoutGridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: gridReuseIdentifier)
        //        self.view.addSubview(collectionView!)
    }
    
    private func setupLayout(with containerSize: CGSize) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            let screenSize: CGRect = UIScreen.main.bounds
            if (screenSize.width == 768) {
                let noOfCellsInRow = 2.5

                let totalSpace = flowLayout.sectionInset.left
                    + flowLayout.sectionInset.right
                    + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

                let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
                
                flowLayout.minimumInteritemSpacing = 20
                flowLayout.minimumLineSpacing = 60
                flowLayout.itemSize = CGSize(width: size, height: size)
                flowLayout.sectionInset = .zero
            } else {
                let noOfCellsInRow = 2

                let totalSpace = flowLayout.sectionInset.left
                    + flowLayout.sectionInset.right
                    + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

                let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
                
                flowLayout.minimumInteritemSpacing = 20
                flowLayout.minimumLineSpacing = 30
                flowLayout.itemSize = CGSize(width: size, height: size)
                flowLayout.sectionInset = .zero
            }
        } else {
            let minItemWidth: CGFloat
            minItemWidth = 92
            let numberOfCell = containerSize.width / minItemWidth
            let width = floor((numberOfCell / floor(numberOfCell)) * minItemWidth)
            let height = ceil(width * (4.0 / 2.8))
            
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: width, height: height)
            flowLayout.sectionInset = .zero
        }
        
        collectionView.reloadData()
    }
    
    private func cometChatUserLogin(){
        if CometChat.getLoggedInUser() == nil {
            CometChat.login(UID: Defaults.readString(key: Defaults.USER_ID), apiKey: ConstantStrings.apiKey, onSuccess: { (current_user) in
                print("Login successful : " + current_user.stringValue())
                let userID:String = current_user.uid!
                let userTopic: String = ConstantStrings.appId + "_user_" + userID + "_ios"
                UserDefaults.standard.set(current_user.uid, forKey: "LoggedInUserID")
                UserDefaults.standard.set(userTopic, forKey: "firebase_user_topic")
                Messaging.messaging().subscribe(toTopic: userTopic) { error in
                    print("Subscribed to \(userTopic) topic")
                }
                self.addUserToMembersChat()
                DispatchQueue.main.async {
                    self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                    self.activityIndicatorView.stopAnimating()
                }
            }) { (error) in
                print("login failure \(error.errorDescription)")
                self.createUser()
            }
        } else {
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private func createUser() {
        let user = User(uid: Defaults.readString(key: Defaults.USER_ID), name: Defaults.readString(key: Defaults.USER_NAME))
        user.role = UserTypes.getUserType().lowercased()
        user.avatar = Defaults.readString(key: Defaults.USER_PORIFLE_PIC)
        user.status = CometChatPro.CometChat.UserStatus.online
        CometChat.createUser(user: user, apiKey: ConstantStrings.apiKey, onSuccess: { (user) in
            if let uid = user.uid {
                self.loginWithUID(uid: uid)
            }
            
        }) { (error) in
            if let error = error?.errorDescription {
                DispatchQueue.main.async {
                    self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                    self.activityIndicatorView.stopAnimating()
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: error, duration: .short)
                    snackbar.show()
                }
                print("Create User failure \(error)")
                
            }
        }
    }
    
    private func loginWithUID(uid: String) {
        CometChat.login(UID: uid, apiKey: ConstantStrings.apiKey, onSuccess: { (current_user) in
            print("Login successful : " + current_user.stringValue())
            let userID:String = current_user.uid!
            let userTopic: String = ConstantStrings.appId + "_user_" + userID + "_ios"
            UserDefaults.standard.set(current_user.uid, forKey: "LoggedInUserID")
            UserDefaults.standard.set(userTopic, forKey: "firebase_user_topic")
            Messaging.messaging().subscribe(toTopic: userTopic) { error in
                print("Subscribed to \(userTopic) topic")
            }
            self.addUserToMembersChat()
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
            }
        }) { (error) in
            print("login failure \(error.errorDescription)")
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private func fetchUserProfileAgain(){
        CloudDataService.sharedInstance.getProfile(ConstantStrings.PROFILE_URL, success: { (json) in
            if (UserTypes.isHMG()) {
                if (json.deals!.count > 0) {
                    self.dealsItems = json.deals!
                } else {
                    self.projectsCollectionView?.setEmptyMessage("no_deals".l10n())
                }
            } else {
                if (json.projects!.count > 0) {
                    self.projectItems = json.projects!
                } else {
                    self.projectsCollectionView?.setEmptyMessage("no_projects".l10n())
                }
            }
            DispatchQueue.main.async {
                self.projectsCollectionView.reloadData()
            }
        }, failure: { (error) in
        })
    }
    
    private func fetchUserProfile(){
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.getProfile(ConstantStrings.PROFILE_URL, success: { (json) in
            Defaults.saveString(key: Defaults.USER_ID, value: json.id!.description)
            Defaults.saveString(key: Defaults.USER_NAME, value: json.firstName! + " " + json.lastName!)
            Defaults.saveString(key: Defaults.USER_TYPE, value: json.type!)
            Defaults.saveString(key: Defaults.USER_PORIFLE_PIC, value: json.profilePicURL)
            Defaults.saveString(key: Defaults.USER_DESIGNATION, value: json.position!)
            OneSignal.setExternalUserId(json.id!.description)
            if (UserTypes.isHMG()) {
                self.seeMore.backgroundColor = UIColor.red
                self.addProjectButton.backgroundColor = UIColor.red
                self.addProjectButton.setTitle("AddNewDeal".l10n(), for: .normal)
                self.projectHeading.text = "Deals".l10n()
                self.seeMore.setTitle("load_more_deals".l10n(), for: .normal)
                if (json.deals!.count > 0) {
                    self.dealsItems = json.deals!
                } else {
                    self.projectsCollectionView?.setEmptyMessage("no_deals".l10n())
                }
            } else {
                self.seeMore.setTitle("load_more".l10n(), for: .normal)
                self.addProjectButton.setTitle("AddNewProject".l10n(), for: .normal)
                self.projectHeading.text = "projects".l10n()
                if (json.projects!.count > 0) {
                    self.projectItems = json.projects!
                } else {
                    self.projectsCollectionView?.setEmptyMessage("no_projects".l10n())
                }
            }
            
            if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("vg")) {
                self.hmgWarningLabel.text = "switchback_hmg".l10n()
                self.hmgWarningView.isHidden = false
                self.hmgWarningConstraint.constant = 32
                self.movies = self.switchedDummyMoviesVG
                self.collectionView.reloadData()
            } else if (!Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).isEmpty && Defaults.readString(key: Defaults.TOGGLER_USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
//                self.movies = Movie.switchedDummyMovies
                self.movies = self.switchedDummyMovies
                self.collectionView.reloadData()
            } else if (Defaults.readString(key: Defaults.USER_TYPE).localizedCaseInsensitiveContains("hmg")) {
                self.movies = self.dummyMovies
                self.collectionView.reloadData()
            } else {
                self.movies = self.dummyMoviesVg
                self.collectionView.reloadData()
            }
            
            self.fetchNews()
            DispatchQueue.main.async {
                self.projectsCollectionView.dataSource = self
                self.projectsCollectionView.delegate = self
                self.projectsCollectionView.backgroundColor = UIColor.dashboardBackground()
                self.setup()
                self.reload()
            }
            self.cometChatUserLogin()
        }, failure: { (error) in
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        })
    }
    
    private func fetchNews() {
        CloudDataService.sharedInstance.getNews(ConstantStrings.NEWS_URL, success: { (json) in
            self.newsItems = json.news
            DispatchQueue.main.async {
                self.reloadNews()
            }
        }, failure: { (error) in
            
        })
    }
    
    private func fetchCountriesAndCities() {
        CloudDataService.sharedInstance.getCities(ConstantStrings.ALL_CITIES, success: { (json) in
            let cities = json.cities
            for city in cities {
                DashboardViewController.citiesList.updateValue(city, forKey: city.id!)
            }
        }, failure: { (error) in
            
        })
        
        CloudDataService.sharedInstance.getCountries(ConstantStrings.ALL_COUNTRIES, success: { (json) in
            let countries = json.countries
            for country in countries {
                DashboardViewController.countriesList.updateValue(country.name!, forKey: country.id!)
            }
        }, failure: { (error) in
            
        })
        
        CloudDataService.sharedInstance.getDepartments(ConstantStrings.DEPARTMENTS, success: { (json) in
            let departments = json.departments
            for department in departments {
                DashboardViewController.departments.updateValue(department, forKey: department.id!)
            }
        }, failure: { (error) in
            
        })
    }
    
    private func addUserToMembersChat() {
        if (Defaults.readString(key: Defaults.USER_TYPE).contains("hmg")) {
            CometChat.joinGroup(GUID: "hmg", groupType: CometChatPro.CometChat.groupType.public, password: nil, onSuccess: { (group) in
                print("Group joined successfully. " + group.stringValue())
            }) { (error) in
                print("joinGroup error:\(String(describing: error?.errorDescription))")
            }
            let groupTopic: String = ConstantStrings.appId + "_group_hmg_ios"
            UserDefaults.standard.set(groupTopic, forKey: "firebase_group_topic")
            Messaging.messaging().subscribe(toTopic: groupTopic) { error in
                print("Subscribed to \(groupTopic) topic")
            }
        } else {
            CometChat.joinGroup(GUID: "vg", groupType: CometChatPro.CometChat.groupType.public, password: nil, onSuccess: { (group) in
                print("Group joined successfully. " + group.stringValue())
            }) { (error) in
                print("joinGroup error:\(String(describing: error?.errorDescription))")
            }
            let groupTopic: String = ConstantStrings.appId + "_group__ios"
            UserDefaults.standard.set(groupTopic, forKey: "firebase_group_topic")
            Messaging.messaging().subscribe(toTopic: groupTopic) { error in
                print("Subscribed to \(groupTopic) topic")
            }
        }
        UserDefaults(suiteName: "group.com.technosoft.VGINV")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// Projects or Deals
extension DashboardViewController: Configurable {
    func setup() {
        // Collection view
        projectsCollectionView?.showsVerticalScrollIndicator = false
        projectsCollectionView?.registerCells()
        
        newCollectionView?.showsVerticalScrollIndicator = false
        newCollectionView?.registerCells()
    }
    
    func config() {
        // Collection view
        guard let cv = projectsCollectionView else { return }
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubviewForAutoLayout(cv)
    }
}

//private extension DashboardViewController {
//    func loadData(_ category: String) {
//        guard let url = NewsApi.urlForCategory(category) else {
//            print("load data error")
//            return
//        }
//
//        items = []
//        projectsCollectionView?.reloadData()
//
//        NewsApi.getArticles(url: url) { [weak self] (articles) in
//            guard let articles = articles else {
//                let ac = UIAlertController(title: nil, message: "Could not get articles 😅", preferredStyle: .alert)
//                ac.addAction(
//                    UIAlertAction.init(title: "OK", style: .default, handler: nil)
//                )
//                self?.present(ac, animated: true, completion: nil)
//                return
//            }
//
//            self?.items = articles
//            self?.reload()
//        }
//    }
//}

extension DashboardViewController: Selectable {
    func didSelect(_ category: String) {
        //        loadData(category)
        
        guard let c = NewsCategory(rawValue: category) else { return }
    }
}
struct ShortCuts {
    
    let title: String
    let description: String
    let posterImage: UIImage?
        
}
// MARK: - Layout
private extension DashboardViewController {
    
    func reload() {
        projectsCollectionView?.reloadData()
        let topIndexPath = IndexPath(row: 0, section: 0)
        projectsCollectionView?.scrollToItem(at: topIndexPath, at: .top, animated: false)
        projectsCollectionView?.collectionViewLayout = listFullWidthLayout
    }
    
    func reloadNews() {
        newCollectionView?.reloadData()
        let topIndexPath = IndexPath(row: 0, section: 0)
        newCollectionView?.scrollToItem(at: topIndexPath, at: .top, animated: false)
        newCollectionView?.collectionViewLayout = listFullWidthLayout
    }
    
    var listFullWidthLayout: UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection? in
            return self.listFullWidthSection
        }
    }
    
    var listFullWidthSection: NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(
            widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
            heightDimension: NSCollectionLayoutDimension.estimated(450)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        
        return section
    }
    
    func reOpenDashboardController() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "DashboardController")
//        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
//        navigationController.modalPresentationStyle = .fullScreen
//        navigationController.title = "Home"
//        navigationController.navigationBar.prefersLargeTitles = true
//        if #available(iOS 13.0, *) {
//            let navBarAppearance = UINavigationBarAppearance()
//            navBarAppearance.configureWithOpaqueBackground()
//
//            navBarAppearance.titleTextAttributes = [ .foregroundColor:  UIColor.label,.font: UIFont (name: "SFProDisplay-Bold", size: 20) as Any]
//            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont(name: "SFProDisplay-Bold", size: 30) as Any]
//            navBarAppearance.shadowColor = .clear
//            navBarAppearance.backgroundColor = .systemBackground
//            navigationController.navigationBar.standardAppearance = navBarAppearance
//            navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
//            self.navigationController?.navigationBar.isTranslucent = false
//        }
//        self.present(navigationController, animated: true, completion: nil)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "host")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}

private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

private extension UICollectionView {
    func registerCells() {
        register(WashingtonCell.self, forCellWithReuseIdentifier: "The Washington Post")
    }
}

private extension UIColor {
    static let newsLightGray = UIColor.colorFor(red: 228, green: 229, blue: 230)
    static let cocoaHubLightGray = UIColor.colorForSameRgbValue(245)
}

private extension UIView {
    
    var readableInset: CGFloat {
        return readableContentGuide.layoutFrame.origin.x
    }
    
}

