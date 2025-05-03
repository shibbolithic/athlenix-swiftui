import UIKit
import Storage
import Supabase

class AddPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!

    @IBOutlet weak var captionTextField: UITextField!

    @IBOutlet weak var addPostButton: UIButton!

    var selectedImageView: UIImageView?
    var gameSuggestions: [GameTable] = [] // Initialize as empty array

    override func viewDidLoad() {
        super.viewDidLoad()

        //Make Image corners rounded
        image1.layer.cornerRadius = 16
        image2.layer.cornerRadius = 16
        image3.layer.cornerRadius = 16
        
        image1.layer.borderWidth = 1
        image2.layer.borderWidth = 1
        image3.layer.borderWidth = 1
        
        image1.layer.borderColor = UIColor.systemGray.cgColor
        image2.layer.borderColor = UIColor.systemGray.cgColor
        image3.layer.borderColor = UIColor.systemGray.cgColor
        
        image1.layer.masksToBounds = true
        image2.layer.masksToBounds = true
        image3.layer.masksToBounds = true

        setupImageTapGestures()
        setupBackButton()

        captionTextField.delegate = self
        setupKeyboardNotifications()
        updateAddPostButtonState()
    }

    private func setupImageTapGestures() {
        if let image1 = image1 {
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
            image1.addGestureRecognizer(tap1)
            image1.isUserInteractionEnabled = true
        }

        if let image2 = image2 {
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
            image2.addGestureRecognizer(tap2)
            image2.isUserInteractionEnabled = true
        }

        if let image3 = image3 {
            let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
            image3.addGestureRecognizer(tap3)
            image3.isUserInteractionEnabled = true
        }
    }

    @objc private func selectImage(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view as? UIImageView else { return }
        selectedImageView = imageView

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let selectedImage = info[.originalImage] as? UIImage {
            selectedImageView?.image = selectedImage
            updateAddPostButtonState() // Update button state after image selection
        }
    }

    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        // Create and configure the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Add activity indicator to button
        sender.addSubview(activityIndicator)
        
        // Center the activity indicator in the button
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
        ])
        
        // Start animating and hide button text
        activityIndicator.startAnimating()
        sender.setTitle("", for: .normal)
        sender.isEnabled = false

        Task { @MainActor in
            guard validateInputs() else {
                // Reset button state if validation fails
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                sender.setTitle("Add Post", for: .normal)
                sender.isEnabled = true
                
                showAlert(title: "Error", message: "Please fill all required fields.")
                return
            }

            let uploadSuccess = await savePostToSupabase()
            
            // Reset button state
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            sender.setTitle("Add Post", for: .normal)
            sender.isEnabled = true

            if uploadSuccess {
                showAlert(title: "Success", message: "Post uploaded successfully!") {
                    self.navigateToHome()
                }
            } else {
                showAlert(title: "Error", message: "Failed to upload post. Please try again.")
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?() // Navigate only on success
        }))
        present(alert, animated: true)
    }

    private func navigateToHome() {
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
                    transition.subtype = .fromLeft // 👈 This makes the screen slide in from the right (left-to-right effect)
                    view.window?.layer.add(transition, forKey: kCATransition)

                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: false, completion: nil) // `animated: false` because we're handling animation manually
                } else {
                    print("❌ Could not instantiate \(viewControllerIdentifier)")
                }
            } catch {
                print("❌ Error fetching user role: \(error.localizedDescription)")
            }
        }
    }

    private func savePostToSupabase() async -> Bool {
        do {
            let imagePaths = try await uploadImages(postID: UUID())
            guard !imagePaths.isEmpty else { return false }

            let newPost = PostsTable(
                postID: UUID(),
                createdBy: await SessionManager.shared.getSessionUser()!,
                content: captionTextField.text ?? "",
                image1: imagePaths.first ?? "",
                image2: imagePaths.dropFirst().first ?? "",
                image3: imagePaths.dropFirst(2).first ?? "",
                linkedGameID: nil,
                likes: 0
            )

            try await supabase.from("posts").insert(newPost).execute()
            return true
        } catch {
            print("Error saving post: \(error)")
            return false
        }
    }

    private func showFailureAlert() {
        let alert = UIAlertController(title: "Error", message: "Failed to upload post. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        // Set chevron.left icon
        backButton.image = UIImage(systemName: "chevron.left")
        //backButton.tintColor = .label // Adapts to light/dark mode
    }

    // Back button action
    @objc private func backButtonTapped() {
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
                    //homeVC.selectedIndex = 2
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

    private func validateInputs() -> Bool {
        if image1.image == nil && image2.image == nil && image3.image == nil {
            print("Error: At least one image must be selected")
            return false
        }

        if captionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            print("Error: Caption cannot be empty")
            return false
        }

        return true
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Post added successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private func uploadImages(postID: UUID) async throws -> [String] {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            throw NSError(domain: "UploadError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No session user is set"])
        }

        let images = [image1.image, image2.image, image3.image]
        var uploadedPaths: [String] = []

        for (index, image) in images.enumerated() {
            guard let image = image, let imageData = image.pngData() else {
                uploadedPaths.append("") // Append an empty string if no image is present
                continue
            }

            let fileName = "image\(index + 1).png"
            let path = "\(sessionUserID.uuidString)/\(postID.uuidString)/\(fileName)"

            try await supabase.storage
                .from("pointt")
                .upload(path: path, file: imageData, options: FileOptions(contentType: "image/png"))

            let publicURL = try await supabase.storage.from("pointt").getPublicURL(path: path)
            uploadedPaths.append(publicURL.absoluteString) // Convert URL to String
        }

        return uploadedPaths
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 3
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateAddPostButtonState()
    }

    // MARK: - Add Post Button State

    private func updateAddPostButtonState() {
        // Only enable button when all three images are selected and caption is not empty
        if image1.image != nil && image2.image != nil && image3.image != nil &&
           !(captionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) {
            addPostButton.isEnabled = true
            addPostButton.alpha = 1.0
        } else {
            addPostButton.isEnabled = false
            addPostButton.alpha = 0.5
        }
    }
}
