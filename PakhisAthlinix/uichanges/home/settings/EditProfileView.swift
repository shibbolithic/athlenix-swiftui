import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Variables
//    @State private var coverImage: Image? = nil
//    @State private var profileImage: Image? = nil
    @State private var coverImage: Image? = Image("16") // Replace with your asset
    @State private var profileImage: Image? = Image("17")
    @State private var name: String = "Alex Johnson"
    @State private var username: String = "alex_j"
    @State private var email: String = "alex@example.com"
    @State private var bio: String = "Basketball enthusiast. Always learning!"
    @State private var height: String = "6.2" // in feet
    @State private var weight: String = "185" // in lbs
    @State private var experience: String = "5" // years
    @State private var selectedPosition: positions = .shootingGuard
    
    @State private var selectedCoverItem: PhotosPickerItem? = nil
    @State private var selectedProfileItem: PhotosPickerItem? = nil
    
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 8) {
                        
                        // 📷 Cover Photo Section
                        coverAndProfileSection
                        
                        // ✍️ Basic Info Section
                        VStack(alignment: .leading, spacing: 8) {
                            Group {
                                Text("Name")
                                    .font(.headline)
                                TextField("Enter Name", text: $name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Username")
                                    .font(.headline)
                                TextField("Enter Username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Email")
                                    .font(.headline)
                                TextField("Enter Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Bio")
                                    .font(.headline)
                                TextField("Enter Bio", text: $bio)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            Divider()
                            
                            Text("Athlete Details")
                                .font(.title2.bold())
                                .padding(.top)
                            
                            Text("Height (in feet)")
                                .font(.headline)
                            TextField("Enter Height", text: $height)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Weight (in lbs)")
                                .font(.headline)
                            TextField("Enter Weight", text: $weight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Experience (years)")
                                .font(.headline)
                            TextField("Enter Experience", text: $experience)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Position")
                                .font(.headline)
                            Picker("Select Position", selection: $selectedPosition) {
                                ForEach(positions.allCases, id: \.self) { pos in
                                    Text(pos.rawValue)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.vertical, 5)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                }
                .navigationBarTitle("Edit Profile", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        saveProfile()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }

    private var coverAndProfileSection: some View {
        ZStack(alignment: .bottom) {
            coverImage!
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color(.systemBackground)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    PhotosPicker(selection: $selectedCoverItem, matching: .images) {
                        Color.clear
                    }
                )
                .onChange(of: selectedCoverItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            coverImage = Image(uiImage: uiImage)
                        }
                    }
                }
            
            profileImage!
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 5)
                .offset(y: UIScreen.main.bounds.width * 0.35 / 3.5)
                .overlay(
                    PhotosPicker(selection: $selectedProfileItem, matching: .images) {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.width * 0.35)
                    }
                    .offset(y: UIScreen.main.bounds.width * 0.35 / 3.5)
                )
                .onChange(of: selectedProfileItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            profileImage = Image(uiImage: uiImage)
                        }
                    }
                }
        }
        .padding(.bottom, UIScreen.main.bounds.width * 0.35 / 2.5)
    }

        
        // MARK: - Save Function
        func saveProfile() {
            print("Saving profile info...")
            print("Name: \(name), Username: \(username)")
            print("Height: \(height), Weight: \(weight)")
            print("Position: \(selectedPosition.rawValue)")
        }
    }
