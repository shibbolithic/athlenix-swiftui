import UIKit
import Storage

class AddTeamViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var teamLogo: UIImageView!
    
    @IBOutlet weak var TeamDetailContainer: UIStackView!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var teamMotto: UITextField!
    
    @IBOutlet weak var addCoachButton: UIButton!
    @IBOutlet weak var addMemberButton: UIButton!
    
    @IBOutlet weak var coachCollectionView: UICollectionView!
    @IBOutlet weak var memberCollectionView: UICollectionView!

   
    @IBOutlet weak var createButton: UIButton!
    
    var selectedCoaches: [Usertable] = [] {
        didSet {
            validateForm()
        }
    }
    var selectedMembers: [Usertable] = [] {
        didSet {
            validateForm()
        }
    }
    @IBOutlet weak var headerNameStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachCollectionView.dataSource = self
        coachCollectionView.delegate = self
        memberCollectionView.delegate = self
        memberCollectionView.dataSource = self
        
        TeamDetailContainer.layer.cornerRadius = 25
        
        // Set up text field delegates
        teamName.delegate = self
        teamMotto.delegate = self
        
        teamLogo.layer.cornerRadius = teamLogo.frame.size.width / 2
        teamLogo.clipsToBounds = true
        
        
        //Add bottom border to headerNameStack View
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: headerNameStack.frame.height - 1, width: headerNameStack.frame.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        headerNameStack.layer.addSublayer(bottomBorder)
        
        // Style text input boxes
        
        // Set up team logo selection
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(teamLogoTapped))
        teamLogo.isUserInteractionEnabled = true
        teamLogo.addGestureRecognizer(tapGesture)
        
        // Set up create button
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        // Initially disable create button
        createButton.isEnabled = false
        createButton.alpha = 0.5
        
        setupBackButton()
        setupKeyboardHandling()
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardHandling() {
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height / 7
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Form Validation
    
    private func validateForm() {
        let isNameValid = !(teamName.text?.isEmpty ?? true)
        let isMottoValid = !(teamMotto.text?.isEmpty ?? true)
        let hasTeamLogo = teamLogo.image != nil
        let hasCoaches = !selectedCoaches.isEmpty
        let hasMembers = !selectedMembers.isEmpty
        
        let isFormValid = isNameValid && isMottoValid && hasTeamLogo && hasCoaches && hasMembers
        
        DispatchQueue.main.async {
            self.createButton.isEnabled = isFormValid
            self.createButton.alpha = isFormValid ? 1.0 : 0.5
        }
    }
    
    // MARK: - Navigation
    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
        // Set chevron.left icon
        backButton.image = UIImage(systemName: "chevron.left")
        
        navigationItem.leftBarButtonItem = backButton
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
    
    // MARK: - Team Creation
    
    @objc private func createButtonTapped() {
        Task {
            guard let name = teamName.text, !name.isEmpty,
                  let motto = teamMotto.text, !motto.isEmpty else {
                showAlert(message: "Please enter a team name and motto.")
                return
            }

            guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
                showAlert(message: "Error: No session user is set.")
                return
            }

            let newTeamID = UUID()
            let currentDateString = ISO8601DateFormatter().string(from: Date())

            var teamLogoURL: String? = nil

            // Upload if a custom image is chosen
            if teamLogo.accessibilityIdentifier == nil, let image = teamLogo.image {
                do {
                    teamLogoURL = try await uploadTeamLogo(image: image, teamID: newTeamID)
                } catch {
                    showAlert(message: "Failed to upload team logo: \(error.localizedDescription)")
                    return
                }
            }

            let newTeam = TeamTable(
                teamID: newTeamID,
                dateCreated: currentDateString,
                teamName: name,
                teamMotto: motto,
                teamLogo: teamLogoURL ?? teamLogo.accessibilityIdentifier ?? "defaultLogo",
                createdBy: sessionUserID
            )

            do {
                try await supabase
                    .from("teams")
                    .insert(newTeam)
                    .execute()

                try await insertTeamMemberships(teamID: newTeamID, users: selectedCoaches, role: .coach)
                try await insertTeamMemberships(teamID: newTeamID, users: selectedMembers, role: .athlete)

                showAlert1(message: "Team created successfully!") { [weak self] in
                    self?.navigateToHome()
                }
            } catch {
                showAlert(message: "Failed to create the team: \(error)")
            }
        }
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
                    transition.subtype = .fromLeft
                    view.window?.layer.add(transition, forKey: kCATransition)
                    
                    homeVC.modalPresentationStyle = .fullScreen
                    self.present(homeVC, animated: false, completion: nil)
                } else {
                    print("❌ Could not instantiate \(viewControllerIdentifier)")
                }
            } catch {
                print("❌ Error fetching user role: \(error.localizedDescription)")
            }
        }
    }
    
    private func uploadTeamLogo(image: UIImage, teamID: UUID) async throws -> String {
        guard let sessionUserID = await SessionManager.shared.getSessionUser() else {
            throw NSError(domain: "UploadError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No session user is set"])
        }

        guard let imageData = image.pngData() else {
            throw NSError(domain: "UploadError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }

        let fileName = "teamLogo.png"
        let path = "\(teamID.uuidString)/\(fileName)"

        try await supabase.storage
            .from("teamlogos")
            .upload(path: path, file: imageData, options: FileOptions(contentType: "image/png"))

        return try await supabase.storage.from("teamlogos").getPublicURL(path: path).absoluteString
    }

    private func insertTeamMemberships(teamID: UUID, users: [Usertable], role: Role) async throws {
        let currentDateString = ISO8601DateFormatter().string(from: Date())
        
        let memberships = users.map { user in
            TeamMembershipTable(
                membershipID: UUID(),
                teamID: teamID,
                userID: user.userID,
                roleInTeam: role,
                dateJoined: currentDateString
            )
        }
        
        // Insert memberships into Supabase
        try await supabase
            .from("teamMembership")
            .insert(memberships)
            .execute()
    }
    
    // MARK: - Alert Dialogs
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showAlert1(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Logo Selection
    
    @objc private func teamLogoTapped() {
        let alert = UIAlertController(title: "Select Logo", message: "Choose a team logo from preloaded logos or pick from your gallery.", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Preloaded Logos", style: .default, handler: { _ in
            let logoSelectionVC = LogoSelectionViewController()
            logoSelectionVC.delegate = self
            let navController = UINavigationController(rootViewController: logoSelectionVC)
            self.present(navController, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default, handler: { _ in
            self.openImagePicker()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    private func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    // MARK: - Team Member Management
    
    @IBAction func addCoachButtonTapped(_ sender: UIButton) {
        let addCoachVC = AddCoachViewController()
        addCoachVC.delegate = self
        let navController = UINavigationController(rootViewController: addCoachVC)
        self.present(navController, animated: true)
    }
    
    func updateCoachCollectionView() {
        DispatchQueue.main.async {
            self.coachCollectionView.reloadData()
            self.validateForm()
        }
    }
    
    @IBAction func addMemberButtonTapped(_ sender: UIButton) {
        let addMemberVC = AddMemberViewController()
        addMemberVC.delegate = self
        let navController = UINavigationController(rootViewController: addMemberVC)
        self.present(navController, animated: true)
    }
    
    func updateMemberCollectionView() {
        DispatchQueue.main.async {
            self.memberCollectionView.reloadData()
            self.validateForm()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == coachCollectionView {
            return selectedCoaches.count
        } else if collectionView == memberCollectionView {
            return selectedMembers.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == coachCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddedCoachesCollectionViewCell", for: indexPath) as! AddedCoachesCollectionViewCell
            let coach = selectedCoaches[indexPath.row]
            cell.configure(with: coach)
            return cell
        } else if collectionView == memberCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddedMembersCollectionViewCell", for: indexPath) as! AddedMemberssCollectionViewCell
            let member = selectedMembers[indexPath.row]
            cell.configure(with: member)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - TextField Delegate
extension AddTeamViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Call validation after a short delay to let the text update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.validateForm()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        validateForm()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == teamName {
            teamMotto.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Delegates
extension AddTeamViewController: AddCoachDelegate {
    func didSelectCoaches(_ coaches: [Usertable]) {
        self.selectedCoaches = coaches
        self.updateCoachCollectionView()
    }
}

extension AddTeamViewController: AddMemberDelegate {
    func didSelectMembers(_ members: [Usertable]) {
        self.selectedMembers = members
        self.updateMemberCollectionView()
    }
}

extension AddTeamViewController: LogoSelectionDelegate {
    func didSelectLogo(named logoName: String) {
        teamLogo.image = UIImage(named: logoName)
        teamLogo.accessibilityIdentifier = logoName
        validateForm()
    }
}

extension AddTeamViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            teamLogo.image = selectedImage
            teamLogo.accessibilityIdentifier = nil // Clear identifier since it's a custom image
            validateForm()
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
