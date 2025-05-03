//
//  sup.swift
//  PakhisAthlinix
//
//  Created by admin65 on 27/04/25.
//

import UIKit
import SwiftUI

class BasketballStatsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        Task{
            if let sessionUserID = await SessionManager.shared.getSessionUser() {
                print("Error: No session user is set")
                
                
                
                let basketballStatsView = BasketballStatsView(currentPlayerID: sessionUserID)
                let hostingController = UIHostingController(rootView: basketballStatsView)
                
                // Add hosting controller as a child
                addChild(hostingController)
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(hostingController.view)
                
                // Constraints to fill the entire view
                NSLayoutConstraint.activate([
                    hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
                
                hostingController.didMove(toParent: self)
                
                let floatingButton = UIButton(type: .system)
                floatingButton.frame = CGRect(x: view.frame.width - 30 - 70, y: view.frame.height - 120 - 70, width: 70, height: 70)
                floatingButton.layer.cornerRadius = 35 // Half of width/height to make it circular
                floatingButton.backgroundColor = UIColor(red: 253/255, green: 100/255, blue: 48/255, alpha: 1.0) // FD6430 color
                floatingButton.setTitle("+", for: .normal)
                floatingButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
                floatingButton.setTitleColor(.white, for: .normal)

                // Add shadow for better visibility
                floatingButton.layer.shadowColor = UIColor.black.cgColor
                floatingButton.layer.shadowOpacity = 0.3
                floatingButton.layer.shadowOffset = CGSize(width: 0, height: 2)
                floatingButton.layer.shadowRadius = 4

                // Add target action for the button
                floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)

        //  Add the button to the view
                view.addSubview(floatingButton)
                return
            }

        }
        

    }
    
    @objc func floatingButtonTapped() {
        // Create an action sheet
        let actionSheet = UIAlertController(title: "Select an Option", message: nil, preferredStyle: .actionSheet)

        // Create "Create Post" action
        let createPostAction = UIAlertAction(title: "Create Post", style: .default) { _ in
            // Handle Create Post action
            self.createPost()
        }

        // Create "Create Team" action
        let createTeamAction = UIAlertAction(title: "Create Team", style: .default) { _ in
            // Handle Create Team action
            self.createTeam()
        }

        // Create "Create Game" action
        let createGameAction = UIAlertAction(title: "Create Game", style: .default) { _ in
            // Handle Create Game action
            self.createGame()
        }

//        Add actions to the action sheet
    actionSheet.addAction(createPostAction)
    actionSheet.addAction(createTeamAction)
    actionSheet.addAction(createGameAction)
    
//         Add a cancel button
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    actionSheet.addAction(cancelAction)
    
    // Present the action sheet
    present(actionSheet, animated: true, completion: nil)
}

// MARK: Create
func createPost() {
    // Code for creating a post
//        let createPostVC = AddPostViewController()
//
//            // Push CreatePostViewController onto the navigation stack
//            navigationController?.pushViewController(createPostVC, animated: true)
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
       if let createPostVC = storyboard.instantiateViewController(withIdentifier: "PostCreationNavigationController") as? PostCreationNavigationController {
           // Present the AddTeamViewController
           createPostVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
           self.present(createPostVC, animated: true, completion: nil)
       } else {
           print("Could not instantiate AddPostViewController")
       }
    print("Create Post tapped")
    
    
    }
    // Add this helper function if needed to refresh the home feed
    private func refreshHomeFeed() {
        print("Home feed refreshed with the new post")
        // Add logic to update the home feed with the new post
    }

func createTeam() {
    // Code for creating a team
    let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
       if let addTeamVC = storyboard.instantiateViewController(withIdentifier: "TeamNavigationController") as? TeamNavigationController {
           // Present the AddTeamViewController
           addTeamVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
           self.present(addTeamVC, animated: true, completion: nil)
       } else {
           print("Could not instantiate AddTeamViewController")
       }
    print("Create Team tapped")
}

func createGame() {
    // Code for creating a game
    let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with your storyboard name if different
       if let addGameVC = storyboard.instantiateViewController(withIdentifier: "GameNavigationController") as? GameNavigationController {
           // Present the AddTeamViewController
           addGameVC.modalPresentationStyle = .fullScreen // or .overFullScreen if you want a different style
           self.present(addGameVC, animated: true, completion: nil)
       } else {
           print("Could not instantiate AddGameViewController")
       }
    print("Create Game tapped")
}
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        guard let rootController = connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }

        var topController = rootController
        while let presentedVC = topController.presentedViewController {
            topController = presentedVC
        }
        return topController
    }
}
