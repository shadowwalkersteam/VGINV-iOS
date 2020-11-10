//
//  ProjectDetailsController.swift
//  VGINV
//
//  Created by Zohaib on 8/3/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import QuickLook

class DownloadFilesCell: UITableViewCell {
    @IBOutlet weak var download: UIImageView!
    @IBOutlet weak var fileName: UILabel!
}

class CommentsCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    var identifier: String?
    var imageSize: CGSize = CGSize(width: 80, height: 80)
    
    func update(image: UIImage?, matchingIdentifier: String?) {
        guard identifier == matchingIdentifier else { return }
        profilePic.image = image
        profilePic.roundImage()
    }
}

class ProjectDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var investButton: UIButton!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var projectImage: UIImageView!
    @IBOutlet weak var projectDesc: UILabel!
    
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var downloadFilesTableView: SelfSizedTableView!
    @IBOutlet weak var commentsTableView: SelfSizedTableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    public static var deals: DealsCatalog? = nil
    public static var projects: ProjectsCatalog? = nil
    
    private var liked = false
    private var projectID = 0
    
    private let downloader = ImageDownloaderNative()
    
    private var assets: [ProjectAssets]? = nil
    private var comments: [ProjectComments]? = nil
    
    var scrollOffset : CGFloat = 0
    var distance : CGFloat = 0
    
    lazy var previewItem = NSURL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        
        investButton.layer.cornerRadius = 24.0
        investButton.layer.borderWidth = 0
        investButton.layer.masksToBounds = true
        
        commentsTableView.maxHeight = 200
        downloadFilesTableView.maxHeight = 300
        
        
        if (UserTypes.isHMG()) {
            investButton.backgroundColor = UIColor.red
            investButton.setTitle("InvestInDeal".l10n(), for: .normal)
        } else {
            investButton.setTitle("InvestInProject".l10n(), for: .normal)
        }
        
        commentField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if (ProjectDetailsController.deals != nil) {
            
            updateWithURL(url: URL(string: (ProjectDetailsController.deals?.dealsImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!), size: CGSize(width: 414,height: 250))
            
//            downloader.getImage(imageUrl: ProjectDetailsController.deals?.dealsImage, size: CGSize(width: 414,height: 250)) { (image) in
//                self.projectImage.image = image
//                self.projectImage.clipsToBounds = true;
//                self.projectImage.contentMode = .scaleAspectFit
//            }
            
            projectTitle.text = ProjectDetailsController.deals?.title
            projectDesc.text = ProjectDetailsController.deals?.description
            projectID = ProjectDetailsController.deals!.id ?? 0
            let likeCounts = ProjectDetailsController.deals?.projectLikes.count
            likedLabel.text = likeCounts!.description + " " + "project_like_hmg".l10n()
            assets = ProjectDetailsController.deals?.projectAssets
            comments = ProjectDetailsController.deals?.projectComments
            fetchDealLikes()
            
        } else {
            downloader.getImage(imageUrl: ProjectDetailsController.projects?.projectsImage, size: CGSize(width: 414,height: 250)) { (image) in
                self.projectImage.image = image
                self.projectImage.contentMode = .scaleAspectFit
                self.projectImage.clipsToBounds = true;
            }
            projectTitle.text = ProjectDetailsController.projects?.title
            projectDesc.text = ProjectDetailsController.projects?.description
            projectID = ProjectDetailsController.projects!.id ?? 0
            let likeCounts = ProjectDetailsController.projects?.projectLikes.count
            likedLabel.text = likeCounts!.description + " " + "project_like_vg".l10n()
            assets = ProjectDetailsController.deals?.projectAssets
            comments = ProjectDetailsController.deals?.projectComments
            fetchProjectsLikes()
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(likeButtonPressed(tapGestureRecognizer:)))
        likeButton.isUserInteractionEnabled = true
        likeButton.addGestureRecognizer(tapGestureRecognizer)
        
        downloadFilesTableView.dataSource = self
        downloadFilesTableView.delegate = self
        
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
    }
    
    func updateWithURL(url: URL?, size: CGSize) {
            let processor = DownsamplingImageProcessor(size: size)
            let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: size.width * UIScreen.main.scale, height: size.height * UIScreen.main.scale))
            projectImage.kf.indicatorType = .activity
            projectImage.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .transition(.fade(1)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage
                ])
            {
                result in
                switch result {
                case .success(let value):
    //                imageView?.image = self.resizeImage(image: image!, newWidth: 40.0)
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
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
            if (UserTypes.isHMG()) {
                set(title: "Deals".l10n(), mode: .automatic)
            } else {
                set(title: "Projects".l10n(), mode: .automatic)
            }
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
    
    @objc func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo
        let keyBoardSize = info![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyBoardSize.height, right: 0.0)
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func likeButtonPressed(tapGestureRecognizer: UITapGestureRecognizer){
        let dict = ["createdAt" : Date().description, "projectId" : projectID.description] as [String : Any]
        CloudDataService.sharedInstance.postLike(params: dict as [String : AnyObject]?, success: { (json) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: json as! String, duration: .short)
            snackbar.show()
            self.likeButton.image = UIImage(named: "liked")
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.downloadFilesTableView) {
            return assets?.count ?? 0
        } else {
            return comments?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.downloadFilesTableView) {
            let asset = assets?[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "downloadFiles", for: indexPath) as! DownloadFilesCell
            cell.backgroundColor = UIColor.dashboardBackground()
            cell.fileName.text = URL(string: asset!.absoluteFilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)?.lastPathComponent
            cell.imageView?.image = UIImage(contentsOfFile: "download")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath) as! CommentsCell
            let comment = comments?[indexPath.row]
            cell.backgroundColor = UIColor.dashboardBackground()
            cell.name.text = (comment?.commentUsers?.firstName)! + " " + (comment?.commentUsers?.lastName!)!
            cell.comment.text = comment?.comment
            cell.identifier = comment?.id?.description
            downloader.getImage(imageUrl: comment?.commentUsers?.profilePicURL, size: cell.imageSize) { (image) in
                cell.update(image: image, matchingIdentifier: comment?.id?.description)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.downloadFilesTableView) {
            let asset = assets?[indexPath.row]
            guard let url = URL(string: asset!.absoluteFilePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
//            UIApplication.shared.open(url)
            self.previewMediaMessage(url: url, completion: {(success, fileURL) in
                if success {
                    if let url = fileURL {
                        self.previewItem = url as NSURL
                        self.presentQuickLook()
                    }
                }
            })
        } else {
            let data = comments?[indexPath.row]
            if (data?.id?.description != Defaults.readString(key: Defaults.USER_ID)) {
                tableView.deselectRow(at: indexPath, animated: true)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "FriendsProfile")
                FriendsProfileController.userID = data?.id?.description ?? ""
                FriendsProfileController.isFriend = true
                let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func investButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "project_interest".l10n(), message: "call_message".l10n(), preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "yes".l10n(), style: UIAlertAction.Style.default, handler: { _ in
            RPicker.selectDate(title: "Select Date & Time", cancelText: "Cancel", datePickerMode: .dateAndTime, minDate: Date(), maxDate: Date().dateByAddingYears(5), didSelectDate: {[weak self] (selectedDate) in
                let dateString = selectedDate.dateString()
                let dateComponents = dateString.components(separatedBy: " ")
                self!.sendCallDetails(date: dateComponents[0] + " " + dateComponents[1] + " " + dateComponents[2], time: dateComponents[3])
                print(dateString)
               })
        }))
        alert.addAction(UIAlertAction(title: "no".l10n(),
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        self.sendInterested()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendInterested() {
        let dict = ["createdAt" : Date().description, "projectId" : projectID.description, "status" : "0"] as [String : Any]
        CloudDataService.sharedInstance.postInvestment(params: dict as [String : AnyObject]?, success: { (json) in
            if (UserTypes.isHMG()) {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "thanks_keep_exploring_deals".l10n(), duration: .short)
                snackbar.show()
                self.backButtonPressed()
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "thanks_keep_exploring_projects".l10n(), duration: .short)
                snackbar.show()
            }
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
            self.backButtonPressed()
        })
    }
    
    func sendCallDetails(date: String, time: String) {
        let dict = ["createdAt" : Date().description, "projectId" : projectID.description, "status" : "2", "call_schedule_date" : date, "call_schedule_time" : time] as [String : Any]
        CloudDataService.sharedInstance.postInvestment(params: dict as [String : AnyObject]?, success: { (json) in
            if (UserTypes.isHMG()) {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "thanks_keep_exploring_deals".l10n(), duration: .short)
                snackbar.show()
                self.backButtonPressed()
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "thanks_keep_exploring_projects".l10n(), duration: .short)
                snackbar.show()
            }
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
            self.backButtonPressed()
        })
    }
    
    func fetchDealLikes() {
        ProjectDetailsController.deals?.projectLikes.forEach { item in
            if (item.id?.description == Defaults.readString(key: Defaults.USER_ID)) {
                liked = true
                self.likeButton.image = UIImage(named: "liked")
                return
            }
        }
    }
    
    func fetchProjectsLikes() {
        ProjectDetailsController.projects?.projectLikes.forEach { item in
            if (item.id?.description == Defaults.readString(key: Defaults.USER_ID)) {
                liked = true
                self.likeButton.image = UIImage(named: "liked")
                return
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        self.view.endEditing(true)
        if (textField.text == "") {
            return false
        }
        let dict = ["createdAt" : Date().description, "projectId" : projectID.description, "comment" : textField.text?.description ?? ""] as [String : Any]
        CloudDataService.sharedInstance.postComment(params: dict as [String : AnyObject]?, success: { (json) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: json as! String, duration: .short)
            snackbar.show()
            textField.text = ""
            self.commentField.text = ""
            self.recallProjects()
        }, failure: { (error) in
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "friendRequestError".l10n(), duration: .short)
            snackbar.show()
        })
        return false
    }
    
    func recallProjects() {
        CloudDataService.sharedInstance.getProfile(ConstantStrings.PROFILE_URL, success: { (json) in
            if (UserTypes.isHMG()) {
                for deals in json.deals! {
                    if (deals.id?.description == self.projectID.description) {
                        self.comments = deals.projectComments
                        self.commentsTableView.reloadData()
                        return
                    }
                }
            } else {
                for project in json.projects! {
                    if (project.id?.description == self.projectID.description) {
                        self.comments = project.projectComments
                        self.commentsTableView.reloadData()
                        return
                    }
                }
            }
        }, failure: { (error) in
            
        })
    }
}

extension Date {
    
    func dateString(_ format: String = "MMMM dd, YYYY HH:mm") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: self)
    }
    
    func dateByAddingYears(_ dYears: Int) -> Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = dYears
        
        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }
}

extension ProjectDetailsController:QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    private func presentQuickLook(){
        DispatchQueue.main.async { [weak self] in
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.navigationController?.title = ""
            self?.present(previewController, animated: true, completion: nil)
        }
    }
    
    func previewMediaMessage(url: URL, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        if (url.description.contains("image")) {
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent )
            var dest = ""
            var destUrl: URL
            if (!url.description.hasSuffix(".png") || !url.description.hasSuffix(".jpg") || !url.description.hasSuffix(".jpeg")) {
                dest = destinationUrl.description + ".jpeg"
                destUrl = URL.init(string: dest)!
            } else {
                destUrl = destinationUrl
            }
            if FileManager.default.fileExists(atPath: destUrl.path) {
                completion(true, destUrl)
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "downloading".l10n(), duration: .long)
                snackbar.animationType = .fadeInFadeOut
                snackbar.show()
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let tempLocation = location, error == nil else { return }
                    do {
                        snackbar.dismiss()
                        var dest = ""
                        var destUrl: URL
                        if (!url.description.hasSuffix(".png") || !url.description.hasSuffix(".jpg") || !url.description.hasSuffix(".jpeg")) {
                            dest = destinationUrl.description + ".jpeg"
                            destUrl = URL.init(string: dest)!
                        } else {
                            destUrl = destinationUrl
                        }
                        try FileManager.default.moveItem(at: tempLocation, to: destUrl)
                        completion(true, destUrl)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completion(false, nil)
                    }
                }).resume()
            }
        } else if (url.description.contains("video")) {
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent )
            var dest = ""
            var destUrl: URL
            if (!url.description.hasSuffix(".mp4") || !url.description.hasSuffix(".flv") || !url.description.hasSuffix(".mkv")) {
                dest = destinationUrl.description + ".mp4"
                destUrl = URL.init(string: dest)!
            } else {
                destUrl = destinationUrl
            }
            if FileManager.default.fileExists(atPath: destUrl.path) {
                completion(true, destUrl)
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "downloading".l10n(), duration: .long)
                snackbar.animationType = .fadeInFadeOut
                snackbar.show()
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let tempLocation = location, error == nil else { return }
                    do {
                        snackbar.dismiss()
                        var dest = ""
                        var destUrl: URL
                        if (!url.description.hasSuffix(".mp4") || !url.description.hasSuffix(".flv") || !url.description.hasSuffix(".mkv")) {
                            dest = destinationUrl.description + ".mp4"
                            destUrl = URL.init(string: dest)!
                        } else {
                            destUrl = destinationUrl
                        }
                        try FileManager.default.moveItem(at: tempLocation, to: destUrl)
                        completion(true, destUrl)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completion(false, nil)
                    }
                }).resume()
            }
        } else if (url.description.hasSuffix(".png") || url.description.hasSuffix(".jpg") || url.description.hasSuffix(".jpeg")) {
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent )
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                completion(true, destinationUrl)
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "downloading".l10n(), duration: .long)
                snackbar.animationType = .fadeInFadeOut
                snackbar.show()
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let tempLocation = location, error == nil else { return }
                    do {
                        snackbar.dismiss()
                        try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                        completion(true, destinationUrl)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completion(false, nil)
                    }
                }).resume()
            }
        } else if (url.description.hasSuffix(".mp4") || url.description.hasSuffix(".flv") || url.description.hasSuffix(".mkv")) {
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent )
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                completion(true, destinationUrl)
            } else {
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "downloading".l10n(), duration: .long)
                snackbar.animationType = .fadeInFadeOut
                snackbar.show()
                URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                    guard let tempLocation = location, error == nil else { return }
                    do {
                        snackbar.dismiss()
                        try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                        completion(true, destinationUrl)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        completion(false, nil)
                    }
                }).resume()
            }
        }
        else {
            UIApplication.shared.open(url)
        }
    }
    
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}
