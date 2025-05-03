//
//  SceneDelegate.swift
//  PakhisAthlinix
//
//  Created by admin65 on 13/12/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        checkAuthenticationStatus()
        
        
    }
    
    private func checkAuthenticationStatus() {
        Task {
            do {
                if let user = try await AuthServices.shared.checkSession() {
                    // Fetch user role
                    let userID = user.id
                    let role = try await fetchUserRole(userID: userID)
                    await MainActor.run {
                        print("Valid session exists, navigate to correct home screen")
                        transitionToHomeScreen(role: role)
                    }
                } else {
                    await MainActor.run {
                        print("No valid session")
                        navigateToLogin()
                    }
                }
            } catch {
                await MainActor.run {
                    print("Session error: \(error)")
                    navigateToLogin()
                }
            }
        }
    }
    
    private func transitionToHomeScreen(role: Role) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("Error: Unable to get window scene")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let storyboardID = (role == .athlete) ? "MainTabBarController" : "CoachMainTabBarController"
        
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: storyboardID) as? UITabBarController else {
            fatalError("\(storyboardID) not found in storyboard")
        }
        
        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.rootViewController = tabBarController
        newWindow.makeKeyAndVisible()
        window = newWindow
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let navigationVC = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navigationVC
            window?.makeKeyAndVisible()
        }
    }

    private func fetchUserRole(userID: UUID) async throws -> Role {
        let response = try await supabase
            .from("User")
            .select("*")
            .eq("userID", value: userID)
            .single()
            .execute()

        let decoder = JSONDecoder()
        let user = try decoder.decode(Usertable.self, from: response.data)
        return user.role
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

