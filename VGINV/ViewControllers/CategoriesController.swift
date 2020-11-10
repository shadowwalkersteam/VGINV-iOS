//
//  CategoriesController.swift
//  VGINV
//
//  Created by Zohaib on 8/15/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import iOSDropDown

class CategoriesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var projectCollectionView: UICollectionView!
    @IBOutlet weak var status: DropDown!
    @IBOutlet weak var categories: DropDown!
    
    private var dealsItems: [DealsCatalog] = []
    private var projectItems: [ProjectsCatalog] = []
    var activityIndicatorView: ActivityIndicatorView!
    private let downloader = ImageDownloaderNative()
    private var isReload = false
    private var departmentID = 0
    private var projectStatus = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.dashboardBackground()
        self.activityIndicatorView = ActivityIndicatorView(title: "pleasewait".l10n(), center: self.view.center)
        projectCollectionView.backgroundColor = UIColor.dashboardBackground()
        
        categories.optionArray = AppHelper.getLocalizedArray(withKey: "AllCategories", targetSpecific: false)
        status.optionArray = AppHelper.getLocalizedArray(withKey: "ProjectStatus", targetSpecific: false)
        
        categories.didSelect{(selectedText , index ,id) in
            for depart in DashboardViewController.departments {
                let parsedDepart = depart.value as! DepartmentsDetails
                if (parsedDepart.depEn == selectedText) {
                    self.departmentID = depart.key
                    break
                } else {
                    self.departmentID = 0
                }
            }
            self.isReload = true
            self.fetchUserProfile(id: self.departmentID, status: self.projectStatus)
        }
        
        status.didSelect{(selectedText , index ,id) in
            self.isReload = true
            if (index == 0 || index == 1) {
                self.projectStatus = 1
                self.fetchUserProfile(id: self.departmentID, status: 1)
            } else {
                self.projectStatus = index
                self.fetchUserProfile(id: self.departmentID, status: index)
            }
        }
        
        categories.selectedIndex = 0
        status.selectedIndex = 0
        
        categories.text = "All"
        status.text = "All Status"
        
        fetchUserProfile(id: 0, status: 1)
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
            set(title: "categoryTitle".l10n(), mode: .automatic)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (Defaults.readString(key: Defaults.USER_TYPE) != nil) {
            if (UserTypes.isHMG()) {
                return dealsItems.count
            } else {
                return projectItems.count
            }
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "The Washington Post", for: indexPath) as! NewsCell
        do {
            if (Defaults.readString(key: Defaults.USER_TYPE) != nil) {
                if (UserTypes.isHMG()) {
                    let article = dealsItems[indexPath.row]
                    let identifier = article.id?.description
                    cell.configureDeals(article)
                    
                     cell.updateWithURL(url: URL(string: article.dealsImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), matchingIdentifier: identifier, size: cell.imageSizeUnwrapped)
//                    downloader.getImage(imageUrl: article.dealsImage, size: cell.imageSizeUnwrapped) { (image) in
//                        cell.update(image: image, matchingIdentifier: identifier)
//                    }
                } else {
                    let article = projectItems[indexPath.row]
                    let identifier = article.id?.description
                    cell.configureProjects(article)
                    
                     cell.updateWithURL(url: URL(string: article.projectsImage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), matchingIdentifier: identifier, size: cell.imageSizeUnwrapped)
//                    downloader.getImage(imageUrl: article.projectsImage, size: cell.imageSizeUnwrapped) { (image) in
//                        cell.update(image: image, matchingIdentifier: identifier)
//                    }
                }
            }
        }  catch {
            print("Couldn't load HomeSoundtrack file")
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
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
    }
    
    private func fetchUserProfile(id: Int, status: Int){
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        CloudDataService.sharedInstance.getProfile(ConstantStrings.PROFILE_URL, success: { (json) in
            Defaults.saveString(key: Defaults.USER_ID, value: json.id!.description)
            Defaults.saveString(key: Defaults.USER_NAME, value: json.firstName! + " " + json.lastName!)
            Defaults.saveString(key: Defaults.USER_TYPE, value: json.type!)
            Defaults.saveString(key: Defaults.USER_PORIFLE_PIC, value: json.profilePicURL)
            Defaults.saveString(key: Defaults.USER_DESIGNATION, value: json.position!)
            self.dealsItems.removeAll()
            self.projectItems.removeAll()
            if (UserTypes.isHMG()) {
                if (json.deals!.count > 0) {
                    for deals in json.deals! {
                        if (id == 0 && deals.status == status) {
                            self.dealsItems.append(deals)
                        } else if (id == deals.depId && deals.status == status) {
                            self.dealsItems.append(deals)
                        }
                    }
                    
                    if (self.dealsItems.count <= 0) {
                        self.projectCollectionView?.setEmptyMessage("no_deals".l10n())
                    } else {
                        self.projectCollectionView.restore()
                    }
                    //                    self.dealsItems = json.deals!
                } else {
                    self.projectCollectionView?.setEmptyMessage("no_deals".l10n())
                }
            } else {
                if (json.projects!.count > 0) {
                    for projects in json.projects! {
                        if (id == 0 && projects.status == status) {
                            self.projectItems.append(projects)
                        } else if (id == projects.depId && projects.status == status) {
                            self.projectItems.append(projects)
                        }
                    }
                    
                    if (self.projectItems.count <= 0) {
                        self.projectCollectionView?.setEmptyMessage("no_projects".l10n())
                    } else {
                        self.projectCollectionView.restore()
                    }
                    //                    self.projectItems = json.projects!
                } else {
                    self.projectCollectionView?.setEmptyMessage("no_projects".l10n())
                }
            }
            
            DispatchQueue.main.async {
                self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.stopAnimating()
                if (self.isReload) {
                    self.projectCollectionView.reloadData()
                } else {
                    self.projectCollectionView.dataSource = self
                    self.projectCollectionView.delegate = self
                    self.projectCollectionView.backgroundColor = UIColor.dashboardBackground()
                    self.setup()
                    self.reload()
                }
            }
        }, failure: { (error) in
            self.view.willRemoveSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.stopAnimating()
        })
    }
}

extension CategoriesController: Configurable {
    func setup() {
        projectCollectionView?.showsVerticalScrollIndicator = false
        projectCollectionView?.registerCells()
    }
    
    func config() {
        guard let cv = projectCollectionView else { return }
        cv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubviewForAutoLayout(cv)
    }
}

private extension CategoriesController {
    func reload() {
        projectCollectionView?.reloadData()
        let topIndexPath = IndexPath(row: 0, section: 0)
        projectCollectionView?.scrollToItem(at: topIndexPath, at: .top, animated: false)
        projectCollectionView?.collectionViewLayout = listFullWidthLayout
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
}

private extension UICollectionView {
    func registerCells() {
        register(WashingtonCell.self, forCellWithReuseIdentifier: "The Washington Post")
    }
}
