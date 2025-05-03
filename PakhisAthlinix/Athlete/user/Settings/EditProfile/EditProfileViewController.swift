//
//  EditProfileViewController.swift
//  PakhisAthlinix
//
//  Created by Vivek Jaglan on 2/11/25.
//

import UIKit
import Storage

class EditProfileViewController: UIViewController {


    //@IBOutlet weak var PositionDropDownOutlet: UIMenu!
    
    @IBOutlet weak var positionDropDownOutlet: UIButton!
    
    @IBOutlet weak var ExperienceTFOutlet: UITextField!
    @IBOutlet weak var WeightTFOutlet: UITextField!
    @IBOutlet weak var fullNameOutlet: UITextField!
    @IBOutlet weak var heightTFOutlet: UITextField!
    @IBOutlet weak var ProfileAvatarOutlet: UIImageView!
    @IBOutlet weak var coverProfileImage: UIImageView!
    
    
    var selectedPosition: positions?  // Store selected position
       
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await fetchUserData()
        }
        setupPositionDropdown()

        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
        ProfileAvatarOutlet.isUserInteractionEnabled = true
        ProfileAvatarOutlet.addGestureRecognizer(profileTapGesture)

        let coverTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCoverImageTap))
        coverProfileImage.isUserInteractionEnabled = true
        coverProfileImage.addGestureRecognizer(coverTapGesture)
    }

       
       // MARK: - Fetch User Data from Supabase
    
       private func fetchUserData() async {
           do {
               if let sessionUserID = await SessionManager.shared.getSessionUser() {
                   let userResponse: [Usertable] = try await supabase
                       .from("User")
                       .select()
                       .eq("userID", value: sessionUserID)
                       .execute()
                       .value
                   
                   let athleteResponse: [AthleteProfileTable] = try await supabase
                       .from("AthleteProfile")
                       .select()
                       .eq("athleteID", value: sessionUserID)
                       .execute()
                       .value
                   
                   if let user = userResponse.first {
                       fullNameOutlet.text = user.name
//                       ProfileAvatarOutlet.image = UIImage(named: user.profilePicture!)
//                       coverProfileImage.image = UIImage(named: user.coverPicture!)
                       
                       if let imageName = user.profilePicture,
                          let localImage = UIImage(named: imageName) {
                           ProfileAvatarOutlet.image = localImage
                       } else if let imageUrlString = user.profilePicture,
                                 let imageUrl = URL(string: imageUrlString) {
                           ProfileAvatarOutlet.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
                       }
                       
                       if let backgroundimageName = user.coverPicture,
                          let localImage = UIImage(named: backgroundimageName) {
                           coverProfileImage.image = localImage
                       } else if let imageUrlString = user.coverPicture,
                                 let imageUrl = URL(string: imageUrlString) {
                           coverProfileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
                       }
                       
                   }
                   
                   if let athlete = athleteResponse.first {
                       heightTFOutlet.text = "\(athlete.height)"
                       WeightTFOutlet.text = "\(athlete.weight)"
                       ExperienceTFOutlet.text = "\(athlete.experience)"
                       selectedPosition = athlete.position
                       positionDropDownOutlet.setTitle(athlete.position.rawValue, for: .normal)
                   }
               }
           } catch {
               print("Error fetching user data: \(error)")
           }
       }
       
       // MARK: - Setup Position Dropdown
    
       private func setupPositionDropdown() {
           let menuItems = positions.allCases.map { position in
               UIAction(title: position.rawValue, handler: { _ in
                   self.selectedPosition = position
                   self.positionDropDownOutlet.setTitle(position.rawValue, for: .normal)
               })
           }
           positionDropDownOutlet.menu = UIMenu(title: "Select Position", options: .displayInline, children: menuItems)
           positionDropDownOutlet.showsMenuAsPrimaryAction = true
       }



    // MARK: - Update User Data in Supabase
    
    private func updateUserData() async {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else { return }

        // Trim spaces and convert text to appropriate data types
        let heightText = heightTFOutlet.text?.trimmingCharacters(in: .whitespaces)
        let heightValue = Float(heightText ?? "") ?? 0.0
        
        let weightText = WeightTFOutlet.text?.trimmingCharacters(in: .whitespaces)
        let weightValue = Float(weightText ?? "") ?? 0.0
        
        let experienceText = ExperienceTFOutlet.text?.trimmingCharacters(in: .whitespaces)
        let experienceValue = Int(experienceText ?? "") ?? 0  // Convert to Int8
        
        let fullNameText = fullNameOutlet.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        
        print("Updating with height: \(heightValue), weight: \(weightValue), experience: \(experienceValue), name: \(fullNameText), position: \(selectedPosition?.rawValue ?? "None")")

        do {
            // Update the 'User' table (for name)
            try await supabase.from("User")
                .update([
                    "name": fullNameText
                ])
                .eq("userID", value: sessionUserID)
                .execute()

            // Update the 'AthleteProfile' table (for experience, height, weight, and position)
            try await supabase.from("AthleteProfile")
                .update([
                    "height": heightValue as Float,
                    "weight": weightValue as Float,
                    "experience": Float(experienceValue) as Float,
                ])
                .eq("athleteID", value: sessionUserID)
                .execute()
            
            try await supabase.from("AthleteProfile")
                .update([
                    "position": selectedPosition?.rawValue ?? ""
                ])
                .eq("athleteID", value: sessionUserID)
                .execute()

            print("Profile updated successfully!")
            
        } catch {
            print("Error updating profile: \(error)")
        }
    }
    
    @objc func handleProfileImageTap() {
        showImageChangeAlert(for: .profile)
    }

    @objc func handleCoverImageTap() {
        showImageChangeAlert(for: .cover)
    }

    enum ImageType {
        case profile
        case cover
    }

    func showImageChangeAlert(for imageType: ImageType) {
        let alert = UIAlertController(title: "Change Image", message: "Do you want to change the image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.openImagePicker(for: imageType)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openImagePicker(for imageType: ImageType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .popover
        imagePicker.view.tag = (imageType == .profile) ? 1 : 2  // Tag to identify the image type
        present(imagePicker, animated: true, completion: nil)
    }




    
    // MARK: - Handle Save Button
    
    @IBAction func handleSave(_ sender: Any) {
        Task{
            await updateUserData()
            
            NotificationCenter.default.post(name: NSNotification.Name("profileUpdated"), object: nil)
            
            showAlert(title: "Success", message: "Your profile has been updated successfully.")
                    
            
//            if let presentingVC = presentingViewController?.presentingViewController {
//                presentingVC.dismiss(animated: true, completion: nil)
//             } else {
//                dismiss(animated: true, completion: nil)
//            }
        }

    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let selectedImage = info[.editedImage] as? UIImage else { return }

        if picker.view.tag == 1 {
            ProfileAvatarOutlet.image = selectedImage
            uploadImageToSupabase(image: selectedImage, for: .profile)
        } else {
            coverProfileImage.image = selectedImage
            uploadImageToSupabase(image: selectedImage, for: .cover)
        }
    }
    
    func uploadImageToSupabase(image: UIImage, for imageType: ImageType) {
        Task {
            guard let sessionUserID = await SessionManager.shared.getSessionUser(),
                  let imageData = image.pngData() else { return }

            let fileName = (imageType == .profile) ? "profile_image.png" : "cover_image.png"
            let path = "pfp/\(sessionUserID)/\(fileName)"
            
            do {
                try await supabase.storage.from("pointt").upload(path: path, file: imageData, options: FileOptions(contentType: "image/png"))
                let publicURL = try await supabase.storage.from("pointt").getPublicURL(path: path)
                print("Image uploaded successfully! URL: \(publicURL)")

                // Update Supabase table with the new image URL
                try await supabase.from("User")
                    .update([(imageType == .profile ? "profilePicture" : "coverPicture"): publicURL.absoluteString])
                    .eq("userID", value: sessionUserID)
                    .execute()
                
                print("Database updated with new image URL.")
            } catch {
                print("Error uploading image to Supabase: \(error)")
            }
        }
    }

}
