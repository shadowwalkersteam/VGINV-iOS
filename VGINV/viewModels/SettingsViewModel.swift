//
//  SettingsViewModel.swift
//  SwiftUI Settings Screen
//
//  Created by Rudrank Riyam on 18/04/20.
//  Copyright © 2020 Rudrank Riyam. All rights reserved.
//

import SwiftUI
import MessageUI
import UIKit

class SettingsViewModel: ObservableObject {
    @Published var bugResult: Result<MFMailComposeResult, Error>? = nil
    @Published var featureResult: Result<MFMailComposeResult, Error>? = nil
    @Published var showPassword = false
    @Published var showingFeatureEmail = false
    @Published var showMailBugAlert = false
    @Published var showMailFeatureAlert = false
    @Published var showShareSheet = false
    @Published var showCreditsView = false
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

    func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")

        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) { return gmailUrl }
        else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) { return outlookUrl }
        else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail){ return yahooMail }
        else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) { return sparkUrl }
        return nil
    }

    func openEditProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Profile")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
    }

    func changePassword() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangePassword")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
    }
}

struct SettingsViewModel_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}
