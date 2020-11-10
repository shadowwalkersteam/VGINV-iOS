//
//  SwiftUIController.swift
//  VGINV
//
//  Created by Zohaib on 8/18/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import Foundation
import SwiftUI

struct ProfileControl: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ProfileControl>) -> ProfileControl.UIViewControllerType {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Profile")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
        
    }
    
    func updateUIViewController(_ uiViewController: ProfileControl.UIViewControllerType, context: UIViewControllerRepresentableContext<ProfileControl>) {
        //
    }
}

struct PasswordControl: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PasswordControl>) -> PasswordControl.UIViewControllerType {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangePassword")
        let navigationController: UINavigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
        
    }
    
    func updateUIViewController(_ uiViewController: PasswordControl.UIViewControllerType, context: UIViewControllerRepresentableContext<PasswordControl>) {
        //
    }
}

struct ActionSheetView: View {
    @State private var showingActionSheet = false
    var body: some View {
        Button(action: {
            self.showingActionSheet = true
        }) {
            Text("Show ActionSheet")
                .font(.title)
                .foregroundColor(Color.white)
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("SwiftUI ActionSheet"), message: Text("How was that"), buttons: [.default(Text("Awesome")), .cancel()])
        }
    }
}
struct ActionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ActionSheetView()
    }
}

struct LanguageControl: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIAlertController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<LanguageControl>) -> LanguageControl.UIViewControllerType {
        
          let alert = UIAlertController(title: "Title", message: "Please Select an Option", preferredStyle: .actionSheet)
              alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { (_) in
                  print("User click Approve button")
              }))

              alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (_) in
                  print("User click Edit button")
              }))

              alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                  print("User click Delete button")
              }))

              alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
                  print("User click Dismiss button")
              }))
        return alert
        
    }
    
    func updateUIViewController(_ uiViewController: LanguageControl.UIViewControllerType, context: UIViewControllerRepresentableContext<LanguageControl>) {
        //
    }
}

struct FullScreenModalView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("This is a modal view")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}
