import UIKit
import Auth

class SignUpViewController: UIViewController {

    @IBOutlet weak var googleButtonOutlet: UIButton!
    @IBOutlet weak var appleButtonOutlet: UIButton!
    @IBOutlet weak var nameTFOutlet: UITextField!
    @IBOutlet weak var hidePasswordBtnOutlet: UIButton!
    @IBOutlet weak var passwordTFOutlet: UITextField!
    @IBOutlet weak var emailTFOutlet: UITextField!
    
    @IBOutlet weak var fullNameStack: UIStackView!
    @IBOutlet weak var emailStack: UIStackView!
    @IBOutlet weak var passwordStack: UIStackView!
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    // Add outlet for signup button
    @IBOutlet weak var signupButtonOutlet: UIButton!
    
    // Error labels for each field
    private var nameErrorLabel: UILabel!
    private var emailErrorLabel: UILabel!
    private var passwordErrorLabel: UILabel!
    
    // Tracking whether user has interacted with each field
    private var nameFieldTouched = false
    private var emailFieldTouched = false
    private var passwordFieldTouched = false
    
    @IBAction func handleLoginWithGoogle(_ sender: Any) {
    }
    
    @IBAction func handleLoginWithApple(_ sender: Any) {
    }
    
    @IBAction func handleHidePassword(_ sender: Any) {
        // Toggle password visibility
        passwordTFOutlet.isSecureTextEntry = !passwordTFOutlet.isSecureTextEntry
        
        // Update button image based on password visibility
        let imageName = passwordTFOutlet.isSecureTextEntry ? "eye.slash" : "eye"
        hidePasswordBtnOutlet.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func handleRegister(_ sender: Any)  {
        // Mark all fields as touched when attempting to register
        nameFieldTouched = true
        emailFieldTouched = true
        passwordFieldTouched = true
        
        // Final validation before submission
        guard validateAllFields() else {
            return // Don't proceed if validation fails
        }
        
        guard let name = nameTFOutlet.text,
              let email = emailTFOutlet.text,
              let password = passwordTFOutlet.text else {
            showAlert(title: "Signup Error", message: "Please fill all fields")
            return
        }
        
        let selectedRole: Role = (roleSegmentedControl.selectedSegmentIndex == 0) ? .athlete : .coach
        
        showLoadingIndicator()
        
        Task {
            do {
                let signUpResult = try await signUp(email: email, password: password, fullName: name)
                print("Signup Success id: \(signUpResult.id)")
                
                let currentDate = ISO8601DateFormatter().string(from: Date())
                
                let userData = Usertable(
                    userID: signUpResult.id,
                    createdAt: currentDate,
                    username: email.components(separatedBy: "@").first ?? "unknown",
                    name: name,
                    email: email,
                    password: password,
                    profilePicture: "person.circle",
                    coverPicture: "1238",
                    bio: nil,
                    dateJoined: currentDate,
                    lastLogin: currentDate,
                    role: selectedRole
                )
                
                let response = try await supabase
                    .from("User")
                    .insert(userData)
                    .execute()
                
                print("Insert status: \(response.status)")
                
                if selectedRole == .athlete {
                    let athleteData = AthleteProfileTable(
                        athleteID: signUpResult.id,
                        height: 0,
                        weight: 0,
                        experience: 0,
                        position: .center,
                        averagePointsPerGame: 0,
                        averageReboundsPerGame: 0,
                        averageAssistsPerGame: 0
                    )
                    
                    let response1 = try await supabase
                        .from("AthleteProfile")
                        .insert(athleteData)
                        .execute()
                    
                    print("Athlete Profile Insert status: \(response1.status)")
                }
                else if selectedRole == .coach {
                    let coachData = CoachProfileTable(
                        coachID: signUpResult.id, yearsOfExperience: 0, specialization: "0", certification: "0"
                    )
                    
                    let response2 = try await supabase
                        .from("CoachProfile")
                        .insert(coachData)
                        .execute()
                    
                    print("Coach Profile Insert status: \(response2.status)")
                }
                
                await MainActor.run {
                    hideLoadingIndicator()
                    transitionToHomeScreen(role: userData.role)
                    showAlert(title: "Signup Success", message: "You have successfully registered to Athlinix")
                }
                
            } catch {
                await MainActor.run {
                    hideLoadingIndicator()
                    showAlert(title: "Exception", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchUserRole(userID: UUID) async throws {
        let response = try await supabase
            .from("User")
            .select("*")
            .eq("userID", value: userID)
            .single()
            .execute()

        print("🔍 Raw Response: \(String(data: response.data, encoding: .utf8) ?? "No Data")")

        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(Usertable.self, from: response.data)
            print("67564345")
            print(user)
            print("67564345")

            
            await MainActor.run {
                transitionToHomeScreen(role: user.role)
                showAlert(title: "Success", message: "Login Successfully")
            }
        } catch {
            print("❌ Decoding Error: \(error.localizedDescription)")
            await MainActor.run {
                showAlert(title: "Error", message: "Data format error")
            }
        }
    }
    
    private func transitionToHomeScreen(role: Role) {
        let storyboardID = (role == .athlete) ? "MainTabBarController" : "CoachMainTabBarController"
        
        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: storyboardID) else {
            fatalError("\(storyboardID) not found in storyboard")
        }
        
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
    
    @IBAction func handleRegisterWithGoogle(_ sender: Any) {
    }
    
    @IBAction func handleRegisterWithApple(_ sender: Any) {
    }
    
    func showAlert(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    func showLoadingIndicator() {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = self.view.center
        loadingIndicator.startAnimating()
        self.view.addSubview(loadingIndicator)
    }
    
    func hideLoadingIndicator() {
        self.view.subviews.forEach { subview in
            if subview is UIActivityIndicatorView {
                subview.removeFromSuperview()
            }
        }
    }
    
    func signUp(email: String, password: String, fullName: String) async throws -> User {
        let auth = try await supabase.auth.signUp(email: email, password: password, data: ["display_name": .string(fullName)] )
        return auth.user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        // Configure UI elements
        setupUI()
        
        // Add error labels
        setupErrorLabels()
        
        // Set up text field delegates
        setupTextFieldDelegates()
        
        // Set initial button state
        updateSignupButtonState()
        
        // Set up keyboard notifications
        setupKeyboardNotifications()
    }
    
    private func setupUI() {
        // Configure Google and Apple buttons
        let buttons = [googleButtonOutlet, appleButtonOutlet]
        buttons.forEach {
            $0?.layer.cornerRadius = 15
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        // Configure input stack views
        let inputBoxes = [fullNameStack, emailStack, passwordStack]
        inputBoxes.forEach {
            $0?.layer.cornerRadius = 15
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        // Configure password field and button
        passwordTFOutlet.isSecureTextEntry = true
        hidePasswordBtnOutlet.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        
        // Make signup button initially disabled
        signupButtonOutlet.isEnabled = false
        signupButtonOutlet.alpha = 0.5
        signupButtonOutlet.layer.cornerRadius = 15
    }
    
    private func setupErrorLabels() {
        // Create and configure error labels
        nameErrorLabel = createErrorLabel()
        emailErrorLabel = createErrorLabel()
        passwordErrorLabel = createErrorLabel()
        
        // Add error labels below their respective stack views
        if let nameStackSuperview = fullNameStack.superview {
            nameStackSuperview.addSubview(nameErrorLabel)
            
            // Position nameErrorLabel below fullNameStack
            nameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                nameErrorLabel.topAnchor.constraint(equalTo: fullNameStack.bottomAnchor, constant: 4),
                nameErrorLabel.leadingAnchor.constraint(equalTo: fullNameStack.leadingAnchor, constant: 8),
                nameErrorLabel.trailingAnchor.constraint(equalTo: fullNameStack.trailingAnchor, constant: -8)
            ])
        }
        
        if let emailStackSuperview = emailStack.superview {
            emailStackSuperview.addSubview(emailErrorLabel)
            
            // Position emailErrorLabel below emailStack
            emailErrorLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                emailErrorLabel.topAnchor.constraint(equalTo: emailStack.bottomAnchor, constant: 4),
                emailErrorLabel.leadingAnchor.constraint(equalTo: emailStack.leadingAnchor, constant: 8),
                emailErrorLabel.trailingAnchor.constraint(equalTo: emailStack.trailingAnchor, constant: -8)
            ])
        }
        
        if let passwordStackSuperview = passwordStack.superview {
            passwordStackSuperview.addSubview(passwordErrorLabel)
            
            // Position passwordErrorLabel below passwordStack
            passwordErrorLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                passwordErrorLabel.topAnchor.constraint(equalTo: passwordStack.bottomAnchor, constant: 4),
                passwordErrorLabel.leadingAnchor.constraint(equalTo: passwordStack.leadingAnchor, constant: 8),
                passwordErrorLabel.trailingAnchor.constraint(equalTo: passwordStack.trailingAnchor, constant: -8)
            ])
        }
    }
    
    private func createErrorLabel() -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }
    
    private func setupTextFieldDelegates() {
        // Set self as delegate for all text fields
        nameTFOutlet.delegate = self
        emailTFOutlet.delegate = self
        passwordTFOutlet.delegate = self
        
        // Add target-action for text fields to track changes
        nameTFOutlet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTFOutlet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTFOutlet.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // Called when text fields change
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // Mark field as touched when user starts typing
        switch textField {
        case nameTFOutlet:
            nameFieldTouched = true
            validateName()
        case emailTFOutlet:
            emailFieldTouched = true
            validateEmail()
        case passwordTFOutlet:
            passwordFieldTouched = true
            validatePassword()
        default:
            break
        }
        
        // Update signup button state
        updateSignupButtonState()
    }
    
    // MARK: - Field Validation Methods
    
    private func validateName() -> Bool {
        guard let name = nameTFOutlet.text else { return false }
        
        let isValid = !name.isEmpty && name.count > 6
        
        // Only show error if the field has been touched and is invalid
        if nameFieldTouched && !isValid {
            if name.isEmpty {
                showErrorForField(nameErrorLabel, message: "Name is required")
            } else {
                showErrorForField(nameErrorLabel, message: "Name must be more than 6 characters")
            }
            return false
        } else {
            hideErrorForField(nameErrorLabel)
            return isValid
        }
    }
    
    private func validateEmail() -> Bool {
        guard let email = emailTFOutlet.text else { return false }
        
        // Check email format and domain
        let hasValidFormat = isValidEmailFormat(email)
        let hasGmailDomain = email.lowercased().hasSuffix("@gmail.com")
        let isValid = !email.isEmpty && hasValidFormat && hasGmailDomain
        
        // Only show error if the field has been touched and is invalid
        if emailFieldTouched && !isValid {
            if email.isEmpty {
                showErrorForField(emailErrorLabel, message: "Email is required")
            } else if !hasValidFormat {
                showErrorForField(emailErrorLabel, message: "Invalid email format")
            } else if !hasGmailDomain {
                showErrorForField(emailErrorLabel, message: "Only gmail.com email addresses are allowed")
            }
            return false
        } else {
            hideErrorForField(emailErrorLabel)
            return isValid
        }
    }
    
    private func validatePassword() -> Bool {
        guard let password = passwordTFOutlet.text else { return false }
        
        // Check password requirements
        let hasMinLength = password.count >= 8
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        
        let isValid = !password.isEmpty && hasMinLength && hasUppercase && hasLowercase && hasNumber
        
        // Only show error if the field has been touched and is invalid
        if passwordFieldTouched && !isValid {
            if password.isEmpty {
                showErrorForField(passwordErrorLabel, message: "Password is required")
            } else if !hasMinLength {
                showErrorForField(passwordErrorLabel, message: "Password must be at least 8 characters")
            } else if !hasUppercase {
                showErrorForField(passwordErrorLabel, message: "Password must contain at least one uppercase letter")
            } else if !hasLowercase {
                showErrorForField(passwordErrorLabel, message: "Password must contain at least one lowercase letter")
            } else if !hasNumber {
                showErrorForField(passwordErrorLabel, message: "Password must contain at least one number")
            }
            return false
        } else {
            hideErrorForField(passwordErrorLabel)
            return isValid
        }
    }
    
    // Validate all fields and return whether all are valid
    private func validateAllFields() -> Bool {
        let nameValid = validateName()
        let emailValid = validateEmail()
        let passwordValid = validatePassword()
        
        return nameValid && emailValid && passwordValid
    }
    
    // Show error message for a field
    private func showErrorForField(_ errorLabel: UILabel, message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    // Hide error message for a field
    private func hideErrorForField(_ errorLabel: UILabel) {
        errorLabel.isHidden = true
    }
    
    // Basic email format validation
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Update signup button enabled/disabled state
    private func updateSignupButtonState() {
        // Check if fields would be valid if they were touched
        let nameText = nameTFOutlet.text ?? ""
        let emailText = emailTFOutlet.text ?? ""
        let passwordText = passwordTFOutlet.text ?? ""
        
        // For button activation, check all fields regardless of touch state
        let nameValid = !nameText.isEmpty && nameText.count > 6
        let emailValid = !emailText.isEmpty && isValidEmailFormat(emailText) && emailText.lowercased().hasSuffix("@gmail.com")
        let passwordValid = !passwordText.isEmpty &&
                          passwordText.count >= 8 &&
                          passwordText.range(of: "[A-Z]", options: .regularExpression) != nil &&
                          passwordText.range(of: "[a-z]", options: .regularExpression) != nil &&
                          passwordText.range(of: "[0-9]", options: .regularExpression) != nil
        
        let isValid = nameValid && emailValid && passwordValid
        
        signupButtonOutlet.isEnabled = isValid
        
        // Visual feedback about button state
        if isValid {
            signupButtonOutlet.alpha = 1.0
        } else {
            signupButtonOutlet.alpha = 0.5
        }
    }
    
    // Set up keyboard notifications
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height/3
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove keyboard observers when view disappears
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Dismiss keyboard when tapping outside text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Handle Return key press for each text field
        switch textField {
        case nameTFOutlet:
            emailTFOutlet.becomeFirstResponder()
        case emailTFOutlet:
            passwordTFOutlet.becomeFirstResponder()
        case passwordTFOutlet:
            textField.resignFirstResponder()
            if signupButtonOutlet.isEnabled {
                handleRegister(textField)
            } else {
                // Mark all fields as touched to show any validation errors
                nameFieldTouched = true
                emailFieldTouched = true
                passwordFieldTouched = true
                validateAllFields()
            }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Mark field as touched when it gains focus
        switch textField {
        case nameTFOutlet:
            nameFieldTouched = true
        case emailTFOutlet:
            emailFieldTouched = true
        case passwordTFOutlet:
            passwordFieldTouched = true
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Validate field when focus is lost
        switch textField {
        case nameTFOutlet:
            validateName()
        case emailTFOutlet:
            validateEmail()
        case passwordTFOutlet:
            validatePassword()
        default:
            break
        }
        
        updateSignupButtonState()
    }
}
