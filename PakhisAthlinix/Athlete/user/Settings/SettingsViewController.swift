//
//  SettingsViewController.swift
//  PakhisAthlinix
//
//  Created by Vivek Jaglan on 2/11/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var ProfileAvatarOutlet: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    
        
        // Do any additional setup after loading the view.
    }
    
    private func updateUI() {
        ProfileAvatarOutlet.layer.cornerRadius = ProfileAvatarOutlet.frame.size.width / 2
        ProfileAvatarOutlet.clipsToBounds = true
    }
    @IBAction func handleLogout(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
            self.performLogout()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    private func performLogout() {
        Task { @MainActor in
            do {
                try await supabase.auth.signOut()
                
                // Navigate to Login Screen
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") // Ensure this ID is set in Storyboard
                    let navController = UINavigationController(rootViewController: loginVC)
                    sceneDelegate.window?.rootViewController = navController
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            } catch {
                print("Logout failed: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        Task {
                guard let userID = await SessionManager.shared.getSessionUser() else {
                    print("User ID is nil")
                    return
                }
                
                do {
                    let userRole = try await fetchUserRole(userID: userID)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewControllerIdentifier = (userRole == .coach) ? "CoachMainTabBarController" : "MainTabBarController"
                    
                    if let homeVC = storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier) as? UITabBarController {
                        let transition = CATransition()
                        transition.duration = 0.3
                        transition.type = .push
                        transition.subtype = .fromLeft
                        view.window?.layer.add(transition, forKey: kCATransition)
                        
                        homeVC.modalPresentationStyle = .fullScreen
                        homeVC.selectedIndex = 2
                        self.present(homeVC, animated: true, completion: nil)
                    } else {
                        print("❌ Could not instantiate \(viewControllerIdentifier)")
                    }
                } catch {
                    print("❌ Error fetching user role: \(error.localizedDescription)")
                }
            }
    }
    
    private func fetchUserRole(userID: UUID) async throws -> Role {
        let response = try await supabase
            .from("User")
            .select("*")
            .eq("userID", value: userID)
            .single()
            .execute()
        
        print("🔍 Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No Data")")
        
        let decoder = JSONDecoder()
        let user = try decoder.decode(Usertable.self, from: response.data)
        
        return user.role
    }
    
}
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


