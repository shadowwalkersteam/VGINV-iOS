//
//  AddNewProjectController.swift
//  VGINV
//
//  Created by Zohaib on 7/5/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import iOSDropDown
import BSImagePicker
import Photos

class AddNewProjectController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var providerDropDown: DropDown!
    @IBOutlet weak var countryDropdown: DropDown!
    @IBOutlet weak var titleProject: UITextField!
    @IBOutlet weak var totalInvestment: UITextField!
    @IBOutlet weak var totalBudget: UITextField!
    @IBOutlet weak var cityDropdown: DropDown!
    @IBOutlet weak var categoriesDropdown: DropDown!
    @IBOutlet weak var projectDescription: UITextView!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var addVideo: UIButton!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var projectDealHeader: UIView!
    @IBOutlet weak var addProjectHeading: UILabel!
    
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    private var countryID = 0
    private var cityID = 0
    private var citiesList: [String] = []
    private var photosURL = ""
    private var videosURL: NSURL? = nil
    private var provider = ""
    private var departmentID = 0
    private var userType = UserTypes.getUserType()
    
    private var photosURLs: [NSURL] = []
    private var videosURLs: [NSURL] = []
    
    private var photosData: [Data] = []
    private var videosData: [Data] = []
    
    var activityIndicatorView: ActivityIndicatorView!
    
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        self.setupNavigationBar()
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.resignFirstResponder()
        self.view.endEditing(true)
        return true
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
            //            self.set(title: "Add New Deal", mode: .never)
            self.addCreateGroup()
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
    
    //    fileprivate func addObservers(){
    //        NotificationCenter.default.addObserver(self, selector: #selector(dismissKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    //        self.hideKeyboardWhenTappedArround()
    //
    //    }
    //
    //    private func hideKeyboardWhenTappedArround() {
    //        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    //        self.view.addGestureRecognizer(tap)
    //    }
    //
    //    @objc  func dismissKeyboard() {
    //        titleProject.resignFirstResponder()
    //        UIView.animate(withDuration: 0.25) {
    //            self.view.layoutIfNeeded()
    //        }
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        if (UserTypes.isHMG()) {
            addProjectHeading.text = "AddNewDeal".l10n()
            self.addImage.backgroundColor = UIColor.red
            self.addVideo.backgroundColor = UIColor.red
            self.submit.backgroundColor = UIColor.red
            projectDealHeader.backgroundColor = UIColor.red
        } else {
            addProjectHeading.text = "AddNewProject".l10n()
        }
        
        //        self.addObservers()
        
        projectDescription.text = "description".l10n()
        titleProject.delegate = self
        projectDescription.delegate = self
        totalInvestment.delegate = self
        totalBudget.delegate = self
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
        addImage.layer.cornerRadius = 24.0
        addImage.layer.borderWidth = 0
        addImage.layer.masksToBounds = true
        
        addVideo.layer.cornerRadius = 24.0
        addVideo.layer.borderWidth = 0
        addVideo.layer.masksToBounds = true
        
        submit.layer.cornerRadius = 24.0
        submit.layer.borderWidth = 0
        submit.layer.masksToBounds = true
        
        projectDealHeader.round(corners: [.bottomLeft], radius: 60)
        
        providerDropDown.optionArray = AppHelper.getLocalizedArray(withKey: "Legals", targetSpecific: false)
        categoriesDropdown.optionArray = AppHelper.getLocalizedArray(withKey: "CategoriesList", targetSpecific: false);
        
        countryDropdown.optionArray = Array(DashboardViewController.countriesList.values.sorted())
        
        countryDropdown.didSelect{(selectedText , index ,id) in
            for countryName in DashboardViewController.countriesList {
                if (selectedText == countryName.value) {
                    self.countryID = countryName.key
                    break
                }
            }
            self.citiesList.removeAll()
            for city in DashboardViewController.citiesList {
                let parsedCity = city.value as! CitiesDetails
                if (parsedCity.countryId == self.countryID) {
                    self.citiesList.append(parsedCity.name!)
                }
            }
            self.cityDropdown.optionArray = self.citiesList.sorted()
        }
        
        cityDropdown.didSelect{(selectedText , index ,id) in
            for city in DashboardViewController.citiesList {
                let parsedCity = city.value as! CitiesDetails
                if (parsedCity.name == selectedText) {
                    self.cityID = city.key
                    break
                }
            }
        }
        
        categoriesDropdown.didSelect{(selectedText , index ,id) in
            for depart in DashboardViewController.departments {
                let parsedDepart = depart.value as! DepartmentsDetails
                if (parsedDepart.depEn == selectedText) {
                    self.departmentID = depart.key
                    break
                }
            }
        }
        
        providerDropDown.didSelect{(selectedText , index ,id) in
            self.provider = selectedText
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        projectDescription.text = String()
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
    
    @IBAction func onImageButtonClicked(_ sender: Any) {
        didAttachmentButtonPressed(button: self.addImage)
    }
    @IBAction func onVideoButtonClicked(_ sender: Any) {
        didAttachmentButtonPressed(button: self.addVideo)
    }
    @IBAction func onSubmitButtonClicked(_ sender: Any) {
        let parameters = [
            "title": titleProject.text?.description ?? "",
            "provider" : provider,
            "description" : projectDescription.text?.description ?? "",
            "city_id" : cityID,
            "country_id" : countryID,
            "budget": totalBudget.text?.description ?? "0",
            "investment" : totalInvestment.text?.description ?? "0",
            "dep_id" : departmentID,
            "created_at" : Date().description,
            "type" : userType
            ] as [String : Any]
        
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.upload2(videoURL: videosURLs, imageURL: photosURLs, params: parameters,  success: { (json) in
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
                                if (self.userType.contains("hmg")) {
                                    self.sendOneSignalNotification(title: "Deal", userName: Defaults.readString(key: Defaults.USER_NAME))
                                    self.showProjectAlert(title: "Deals".l10n(), message: "ProjectPostedHMG".l10n())
                                } else {
                                    self.sendOneSignalNotification(title: "Project", userName: Defaults.readString(key: Defaults.USER_NAME))
                                    self.showProjectAlert(title: "project".l10n(), message: "ProjectPosted".l10n())
                                }
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
                                if (self.userType.contains("hmg")) {
                                    self.showProjectAlert(title: "Deals".l10n(), message: "ProjectPostFailHMG".l10n())
                                } else {
                                    self.showProjectAlert(title: "project".l10n(), message: "ProjectPostFail".l10n())
                                }
            }
        })
    }
    
    private func sendOneSignalNotification(title : String, userName : String) {
        let notificationContent = [
            "included_segments": ["All"],
            "contents": ["en": userName + " has posted a new " + title + "."],
            "headings": ["en": "New" + title],
            "data": ["foo": "bar"],
            "android_channel_id": "163157c3-fe29-49c0-b9bf-f713dc59eff4",
            "app_id": "af0bb11e-f674-47a8-8718-bc1c78c36019"
        ] as [String : Any]

        CloudDataService.sharedInstance.sendOneSignalNotification(ConstantStrings.ONESIGNAL, params: notificationContent as [String : AnyObject]?, success: { (json) in

        }, failure: { (error) in
            print(error)
        })
    }
    
    private func showProjectAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok".l10n(), style: UIAlertAction.Style.cancel, handler: { _ in
            self.backButtonPressed()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    public func didAttachmentButtonPressed(button: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "PHOTO_&_VIDEO_LIBRARY".l10n(), style: .default) { action -> Void in
            //            CameraHandler.shared.presentPhotoLibrary(for: self)
            //            CameraHandler.shared.imagePickedBlock = {(photoURL) in
            //                self.photosURL = photoURL
            //                print(photoURL)
            //                self.addImage.setTitle("image0.png", for: .normal)
            //            }
            
            self.showImagePicker()
            
            //            CameraHandler.shared.videoPickedBlock2 = {(videoURL) in
            //                self.videosURL = videoURL
            //                print(videoURL)
            //                self.addVideo.setTitle("video0.mov", for: .normal)
            //            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel".l10n(), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(photoLibraryAction)
        //        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            if let currentPopoverpresentioncontroller =
                actionSheetController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = button
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    private func showImagePicker() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 10
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = true
        
        self.presentImagePicker(imagePicker, select: { (asset) in
            
        }, deselect: { (asset) in
            
        }, cancel: { (assets) in
            
        }, finish: { (assets) in
            
            for asset in assets {
                self.getAssetUrl(mPhasset: asset)
//                self.getAssetThumbnail(asset: asset, size: CGFloat(signOf: 500, magnitudeOf: 500))
            }
            
        }, completion: {
            
        })
    }
    
    func getAssetThumbnail(asset: PHAsset, size: CGFloat) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        imageManager.requestImageData(for: asset, options: options, resultHandler: {
            imageData,dataUTI,orientation,info in
            let ciImage = CIImage(data: imageData!)
            if #available(iOS 10.0, *) {
                let data = CIContext().jpegRepresentation(of: ciImage!, colorSpace: CGColorSpaceCreateDeviceRGB())!
                // upload image data
                self.photosData.append(data)
            }
            
            //        let retinaScale = UIScreen.main.scale
            //        let retinaSquare = CGSize(width: size * retinaScale, height: size * retinaScale)
            //        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
            //        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
            //        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
            //
            //        let manager = PHImageManager.default()
            //        let options = PHImageRequestOptions()
            //        var thumbnail = UIImage()
            //
            //        options.isSynchronous = true
            //        options.deliveryMode = .highQualityFormat
            //        options.resizeMode = .exact
            //
            //        options.normalizedCropRect = cropRect
            //
            //        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options, resultHandler: {(result, info)->Void in
            //            thumbnail = result!
            //            let imgData = thumbnail.jpegData(compressionQuality: 0.2)!
            //            self.photosData.append(imgData)
            //        })
            //        return thumbnail
        })
    }
    
    func getAssetUrl(mPhasset : PHAsset){
        
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.isNetworkAccessAllowed = true
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                let responseURL = contentEditingInput!.fullSizeImageURL
                self.photosURLs.append(responseURL! as NSURL)
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl : NSURL = urlAsset.url as NSURL
                    self.videosURLs.append(localVideoUrl)
                }
            })
        }
        
    }
    
    func fromHeicToJpg(heicPath: String, jpgPath: String) -> String? {
        let heicImage = UIImage(named:heicPath)
        let jpgImageData = heicImage!.jpegData(compressionQuality: 1.0)
        FileManager.default.createFile(atPath: jpgPath, contents: jpgImageData, attributes: nil)
        return jpgPath
        //        let jpgImage = UIImage(named: jpgPath)
        //        return jpgImage
    }
}
