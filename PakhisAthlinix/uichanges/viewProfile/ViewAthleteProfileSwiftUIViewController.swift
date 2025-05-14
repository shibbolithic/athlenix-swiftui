//
//  AthleteProfileSwiftUIViewController.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/05/25.
//
import UIKit
import SwiftUI
import Supabase

class ViewAthleteProfileSwiftUIViewController: UIViewController {
    
    let userId: UUID
    
    init(userId: UUID) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }
    
    private func setupSwiftUIView() {
        // Create the SwiftUI view with the userId
        let athleteProfileView = ViewAthleteProfileView(userId: userId)
        
        // Create a UIHostingController with the SwiftUI view
        let hostingController = UIHostingController(rootView: athleteProfileView)
        
        // Add as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        // Configure constraints
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Notify the hosting controller that it has moved to the parent
        hostingController.didMove(toParent: self)
    }
}
