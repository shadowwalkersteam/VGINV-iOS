//
//  EditProfileController.swift
//  VGINV
//
//  Created by Zohaib on 8/21/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import iOSDropDown

class EditProfileController: UIViewController, UITextFieldDelegate {
    private let downloader = ImageDownloaderNative()
    var activityIndicatorView: ActivityIndicatorView!
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var position: UITextField!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var projects: UILabel!
    @IBOutlet weak var deals: UILabel!
    @IBOutlet weak var favorites: UILabel!
    @IBOutlet weak var bio: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: DropDown!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cityDropdown: DropDown!
    @IBOutlet weak var departmentDropdown: DropDown!
    @IBOutlet weak var save2: UIButton!
    @IBOutlet weak var chooseImage: UIImageView!
    
    
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    private var countryID = 0
    private var cityID = 0
    private var citiesList: [String] = []
    private var photosURL = ""
    private var departmentID = 0
    
    
    @IBAction func saveClicked(_ sender: Any) {
        var departmentArray: [String] = []
        departmentArray.append(departmentID.description)
        let fullName = name.text?.description.split(separator: " ")
        let parameters = [
            "first_name": fullName?[0] ?? "",
            "last_name" : fullName?[1] ?? "",
            "email" : email.text?.description ?? "",
            "phone" : phone.text?.description ?? "",
            "description" : bio.text?.description ?? "",
            "position": position.text?.description ?? "",
            "city_id" : cityID,
            "departments[0]" : departmentID.description
            ] as [String : Any]
        
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.saveProfile(imageURL: photosURL, params: parameters,  success: { (json) in
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
                let alert = UIAlertController(title: "profile", message: "profileChangeSuccesss".l10n(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok".l10n(), style: UIAlertAction.Style.cancel, handler: { _ in
                    self.backButtonPressed()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { (error) in
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
                
                let alert = UIAlertController(title: "profile".l10n(), message: "profileChangeError".l10n(), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "Ok".l10n(), style: UIAlertAction.Style.cancel, handler: { _ in
                    self.backButtonPressed()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        
        saveButton.setTitle("save".l10n(), for: .normal)
        
        saveButton.layer.cornerRadius = 24.0
        saveButton.layer.borderWidth = 0
        saveButton.layer.masksToBounds = true
        
        save2.layer.cornerRadius = 24.0
        save2.layer.borderWidth = 0
        save2.layer.masksToBounds = true
        
        if (UserTypes.isHMG()) {
            self.saveButton.backgroundColor = UIColor.red
        }
        
        self.hideKeyboardWhenTappedAround()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseProfile(tapGestureRecognizer:)))
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(tapGestureRecognizer)
        
        name.delegate = self
        bio.delegate = self
        email.delegate = self
        phone.delegate = self
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidShow(notification:)),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardDidHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        fetchUserProfile()
        
        departmentDropdown.optionArray = AppHelper.getLocalizedArray(withKey: "CategoriesList", targetSpecific: false);
        
        address.optionArray = Array(DashboardViewController.countriesList.values.sorted())
        
        address.didSelect{(selectedText , index ,id) in
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
        
        departmentDropdown.didSelect{(selectedText , index ,id) in
            for depart in DashboardViewController.departments {
                let parsedDepart = depart.value as! DepartmentsDetails
                if (parsedDepart.depEn == selectedText) {
                    self.departmentID = depart.key
                    break
                }
            }
        }
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
    
    @objc func chooseProfile(tapGestureRecognizer: UITapGestureRecognizer){
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "choseFile".l10n(), style: .default) { action -> Void in
            CameraHandler.shared.presentPhotoLibrary(for: self)
            CameraHandler.shared.imagePickedBlock = {(photoURL) in
                self.photosURL = photoURL
                print(photoURL)
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "cancel".l10n(), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(photoLibraryAction)
        actionSheetController.addAction(cancelAction)
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            if let currentPopoverpresentioncontroller =
                actionSheetController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = self.chooseImage
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            self.present(actionSheetController, animated: true, completion: nil)
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
        backButton.addTarget(self, action: #selector(self.openHost), for: .touchUpInside)
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
            self.position.text = json.position!
            self.phone.text = json.phone!
            self.email.text = json.email!
            self.bio.text = json.description!
            self.favorites.text = json.departments[0].departments.depEn
            self.departmentID = json.departments[0].departments.id ?? 0
            if (json.city != nil) {
                
            }
            //            self.address.text = (json.city?.cityName)! + ", " + (json.city?.country?.countryName)!
            
            var tempCountryID = 0
            for country in DashboardViewController.countriesList {
                if (json.city?.country?.countryName == country.value) {
                    tempCountryID = country.key
                    self.countryID = tempCountryID
                    self.address.text = country.value
                    break
                }
            }
            
            self.citiesList.removeAll()
            for city in DashboardViewController.citiesList {
                let parsedCity = city.value as! CitiesDetails
                if (parsedCity.countryId == tempCountryID) {
                    self.citiesList.append(parsedCity.name!)
                }
            }
            
            self.cityDropdown.text = json.city?.cityName
            self.cityDropdown.optionArray = self.citiesList.sorted()
            
            for city in DashboardViewController.citiesList {
                let parsedCity = city.value as! CitiesDetails
                if (parsedCity.name == json.city?.cityName) {
                    self.cityID = city.key
                    break
                }
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
    
    @objc func openHost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "host")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
}
