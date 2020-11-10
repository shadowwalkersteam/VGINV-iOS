//
//  CloudDataService.swift
//  VGINV
//
//  Created by Zohaib on 6/20/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class CloudDataService: NSObject {
    
    static let sharedInstance = CloudDataService()
    
    func userLogin(_ strURL : String, params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        AF.request(URL.init(string: strURL)!, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["success"] as? Bool {
                            if (res) {
                                let token = json["token"] as? String
                                print(token!)
                                Defaults.saveString(key: Defaults.TOKEN, value: token!)
                                success(res)
                            } else {
                                failure(res)
                            }
                        }
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func sendOneSignalNotification(_ strURL : String, params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": "Basic Yzc1M2Y4NTAtZjNkNC00NDExLWE5NTgtNTdjMWIwMmQzN2Nl"
        ]
        AF.request(URL.init(string: strURL)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        print(json)
                    }
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func getGroupChats(_ strURL : String, success:@escaping (Groups) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseDecodable(of: Groups.self) { (response) in
            guard let groups = response.value else { return }
            success(groups)
        }
    }
    
    func getProfile(_ strURL : String, success:@escaping (UserProfile) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseDecodable(of: UserProfile.self) { (response) in
            switch response.result {
            case .success(_):
                guard let profile = response.value else { return }
                success(profile)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch Profile")
            }
        }
    }
    
    func getNews(_ strURL : String, success:@escaping (NewsModel) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseDecodable(of: NewsModel.self) { (response) in
            switch response.result {
            case .success(_):
                guard let profile = response.value else { return }
                success(profile)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch News")
            }
        }
    }
    
    func getCountries(_ strURL : String, success:@escaping (Countries) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseDecodable(of: Countries.self) { (response) in
            switch response.result {
            case .success(_):
                guard let countries = response.value else { return }
                success(countries)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch Countries")
            }
        }
    }
    
    func getCities(_ strURL : String, success:@escaping (Cities) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseDecodable(of: Cities.self) { (response) in
            switch response.result {
            case .success(_):
                guard let cities = response.value else { return }
                success(cities)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch Countries")
            }
        }
    }
    
    func getDepartments(_ strURL : String, success:@escaping (Departments) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseDecodable(of: Departments.self) { (response) in
            switch response.result {
            case .success(_):
                guard let departments = response.value else { return }
                success(departments)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch Countries")
            }
        }
    }
    
    func upload(videoURL: NSURL?, imageURL: String, params: [String: Any], success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
            }
            if (videoURL != nil) {
                //                let vidFileUrl = NSURL.fileURL(withPath: videoURL.replacingOccurrences(of: "file:///", with: "", options: String.CompareOptions.regularExpression, range: nil))
                multiPart.append(videoURL as! URL, withName: "studies", fileName: "SampleVideo", mimeType: "*/*")
            }
            if (imageURL != "") {
                multiPart.append(NSURL(string: imageURL)! as URL, withName: "images", fileName: "SampleImage", mimeType: "image/*")
            }
        }, to: ConstantStrings.POST_PROJECT, method: .post, headers: headers)
            .uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON(completionHandler: { data in
                print(data)
                switch data.result {
                case .success(_):
                    success("posted")
                case .failure(let error):
                    failure("We are fucked")
                    print("error in decoding",error.localizedDescription)
                }
            })
    }
    
    func upload2(videoURL: [NSURL], imageURL: [NSURL], params: [String: Any], success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
            }
            if (videoURL.count > 0) {
                for url in videoURL {
                    multiPart.append(url as URL, withName: "studies", fileName: url.description.fileName() + "video" , mimeType: "*/*")
                }
            }
            if (imageURL.count > 0) {
                for url in imageURL {
                    multiPart.append(url as URL, withName: "images", fileName: url.description.fileName() + "image" , mimeType: "image/png")
                }
            }
        }, to: ConstantStrings.POST_PROJECT, method: .post, headers: headers)
            .uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON(completionHandler: { data in
                print(data)
                switch data.result {
                case .success(_):
                    success("posted")
                case .failure(let error):
                    failure("We are fucked")
                    print("error in decoding",error.localizedDescription)
                }
            })
    }
    
    func getAllUsers(url: String, params: [String: Any], success:@escaping (AllUsers) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.queryString, headers: headers).responseDecodable(of: AllUsers.self) { (response) in
            switch response.result {
            case .success(_):
                guard let profile = response.value else { return }
                success(profile)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch All Users")
            }
        }
    }
    
    func sendFriendRequest(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.USER_ADD_FRIEND)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            if (res.contains("Request has been sent successfully")) {
                                success("")
                            } else {
                                failure("")
                            }
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func unFriendUser(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.DELETE_MEMBER)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            success(res)
                        } else {
                            failure("")
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func getAllFriends(success:@escaping (AllUsers) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(ConstantStrings.USER_FRIENDS, method: .get, parameters: nil, headers: headers).responseDecodable(of: AllUsers.self) { (response) in
            switch response.result {
            case .success(_):
                guard let profile = response.value else { return }
                success(profile)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch All Users")
            }
        }
    }
    
    func getNotifications(success:@escaping (Notifications) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(ConstantStrings.NOTIFICATIONS, method: .get, parameters: nil, headers: headers).responseDecodable(of: Notifications.self) { (response) in
            switch response.result {
            case .success(_):
                guard let notifications = response.value else { return }
                success(notifications)
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch Countries")
            }
        }
    }
    
    func getAllUsers2(_ strURL: String, success:@escaping (UserProfile) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(strURL, method: .get, parameters: nil, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                let result = response.data
                do{
                    let decoder = JSONDecoder()
                    let weatherModel = try decoder.decode(UserProfile.self, from: result!)
                    print(weatherModel.deals)
                }catch let error{
                    print("error in decoding",error.localizedDescription)
                    failure("Couldn't Fetch All Users")
                    
                }
            case .failure(let error):
                print("error in decoding",error.localizedDescription)
                failure("Couldn't Fetch All Users")
            }
        }
    }
    
    func acceptRequest(url: String, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: url)!, method: .post, parameters: nil, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            success(res)
                        } else {
                            failure("")
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func toggleUser(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.USER_TOGGLE)!, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            if (res.contains("switched to hmg")) {
                                success(true)
                            } else {
                                success(false)
                            }
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func switchToHmg(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.SWITCH_HMG)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["status"] as? String {
                            success(true)
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func postLike(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.LIKE)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            success(res)
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func postComment(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.COMMENT)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            success(res)
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func postInvestment(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.INVEST)!, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            success(res)
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func changePassword(params : [String : AnyObject]?, success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void){
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.request(URL.init(string: ConstantStrings.CHANGE_PASSWORD)!, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success(_):
                do {
                    if let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as? [String: Any] {
                        if let res = json["msg"] as? String {
                            if (res.contains("password changed successfully")) {
                                success(true)
                            } else {
                                success(false)
                            }
                        }
                    }
                } catch let error as NSError {
                    failure("")
                    print("Failed to load: \(error.localizedDescription)")
                }
                break
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    func saveProfile(imageURL: String, params: [String: Any], success:@escaping (Any) -> Void, failure:@escaping (Any) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": Defaults.readString(key: Defaults.TOKEN)
        ]
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
            }
            if (imageURL != "") {
                multiPart.append(NSURL(string: imageURL)! as URL, withName: "image", fileName: "SampleImage", mimeType: "image/*")
            }
        }, to: ConstantStrings.CHANGE_PROFILE, method: .put, headers: headers)
            .uploadProgress(queue: .main, closure: { progress in
                //Current upload progress of file
                print("Upload Progress: \(progress.fractionCompleted)")
            })
            .responseJSON(completionHandler: { data in
                print(data)
                switch data.result {
                case .success(_):
                    success("posted")
                case .failure(let error):
                    failure("We are fucked")
                    print("error in decoding",error.localizedDescription)
                }
            })
    }
}

extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
