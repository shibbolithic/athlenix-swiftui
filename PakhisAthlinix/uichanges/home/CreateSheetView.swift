//
//  CreateSheetView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 03/05/25.

import SwiftUICore
import SwiftUI

struct CreateSheetView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 16) {
            Text("Create")
                .font(.headline)
                .foregroundColor(.orange)
                .padding(.top)
            
            Divider()

            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let topVC = UIApplication.shared.topMostViewController() {
                        let gameVC = GameNavigationController()
                        topVC.present(gameVC, animated: true)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "basketball.fill").foregroundColor(.gray)
                    Text("Game").foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let topVC = UIApplication.shared.topMostViewController() {
                        let gameVC = PostCreationNavigationController()
                        topVC.present(gameVC, animated: true)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "square.grid.3x3.fill").foregroundColor(.gray)
                    Text("Post").foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Divider()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let topVC = UIApplication.shared.topMostViewController() {
                        let gameVC = CreateGameViewController()
                        topVC.present(gameVC, animated: true)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "person.3.fill").foregroundColor(.gray)
                    Text("Team").foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
    }

    func presentUIKitVC(vc: UIViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        rootVC.present(vc, animated: true, completion: nil)
    }
}
