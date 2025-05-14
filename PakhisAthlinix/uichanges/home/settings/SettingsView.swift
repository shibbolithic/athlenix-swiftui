//
//  SettingsView.swift
//  PakhisAthlinix
//
//  Created by admin65 on 11/05/25.
//


import SwiftUI

struct SettingsView: View {
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: EditProfileView()) {
                        Label("Edit Profile", systemImage: "pencil.circle")
                    }
                }
                
                Section {
                    NavigationLink(destination: TermsAndConditionsView()) {
                        Label("Terms & Conditions", systemImage: "doc.text")
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        Label("FAQs", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Account", systemImage: "trash")
                    }
                    .alert("Are you sure you want to delete your account? This action cannot be undone.", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            // Handle delete logic
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    
                    Button {
                        showLogoutAlert = true
                    } label: {
                        Label("Log Out", systemImage: "arrow.backward.circle")
                    }
                    .alert("Log out of your account?", isPresented: $showLogoutAlert) {
                        Button("Log Out", role: .destructive) {
                            // Handle logout logic
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    SettingsView()
}
