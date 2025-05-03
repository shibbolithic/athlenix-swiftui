//
//  UIKitNavigationBridge.swift
//  PakhisAthlinix
//
//  Created by admin65 on 03/05/25.
//


import SwiftUI

struct UIKitNavigationBridge: UIViewControllerRepresentable {
    var navigationController: UINavigationController?
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Just a placeholder
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    // Helper methods to navigate to different view controllers
    func navigateToAddPost() {
        let vc = AddPostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToAddTeam() {
        let vc = AddTeamViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigateToAddMember() {
        let vc = AddMemberDetailsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
