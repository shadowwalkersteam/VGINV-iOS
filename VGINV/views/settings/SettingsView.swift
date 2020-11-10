//
//  SettingsView.swift
//  SwiftUI Settings Screen
//
//  Created by Rudrank Riyam on 18/04/20.
//  Copyright © 2020 Rudrank Riyam. All rights reserved.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel = SettingsViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // MARK: - SHARE
                    SettingsRow(imageName: "person.icloud", title: NSLocalizedString("editProfile", comment: "")) {
//                        self.settingsViewModel.openEditProfile()
                        self.settingsViewModel.showShareSheet = true
                    }
                    .sheet(isPresented: $settingsViewModel.showShareSheet) {
                       ProfileControl()
                    }
                    // MARK: - WRITE REVIEW
                    SettingsRow(imageName: "pencil.and.outline", title: NSLocalizedString("changePassword", comment: "")) {
                        self.settingsViewModel.showPassword = true
                    }
                    .sheet(isPresented: $settingsViewModel.showPassword) {
                       PasswordControl()
                    }

                    // MARK: - TWEET ABOUT IT
                    SettingsRow(imageName: "textbox", title: NSLocalizedString("Change_Language", comment: "")) {
//                        self.settingsViewModel.changePassword()
                        self.settingsViewModel.showMailBugAlert = true
                        ActionSheetView()
                    }
//                    .alert(isPresented: self.$settingsViewModel.showMailBugAlert) {
//                        Alert(title: Text(NSLocalizedString("Change_Language", comment: "")), message: Text("Please set up a Mail account in order to send email"), dismissButton: .default(Text("OK")))
//                    }
                }
                .settingsBackground()
                
                VStack {
                    AppVersionRow(imageName: "info.circle", title: "App version", version: settingsViewModel.appVersion)
                }
                .settingsBackground()
                AboutView(title: "Copyright 2020-2022 © VGINV", accessibilityTitle: "")
            }
            .navigationBarTitle("Settings")
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
