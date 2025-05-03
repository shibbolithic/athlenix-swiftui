import UIKit

class LoginViewController: UIViewController {
    // Keep all your existing properties and outlets
    var window: UIWindow?
    @IBOutlet weak var googleButtonOutlet: UIButton!
    @IBOutlet weak var appleButtonOutlet: UIButton!
    @IBOutlet weak var emailTFOutlet: UITextField!
    @IBOutlet weak var EmailInputBox: UIStackView!
    @IBOutlet weak var LoginButtonOutlet: UIButton!
    @IBOutlet weak var PasswordInputBox: UIStackView!
    @IBOutlet weak var passwordTFOutlet: UITextField!
    @IBOutlet weak var togglePasswordOutlet: UIButton!
    let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tap gesture for dismissing keyboard (keeping this as it's a good addition)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)

        emailTFOutlet.delegate = self
        passwordTFOutlet.delegate = self

        // Add text change observers for validation
        emailTFOutlet.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTFOutlet.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        setupActivityIndicator()
        setupUI()
        setupKeyboardNotifications()

        // Initial validation of login button
        validateLoginButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove keyboard notifications when view is disappearing
        NotificationCenter.default.removeObserver(self)
    }

    // Method to validate and update login button state
    @objc private func textFieldDidChange(_ textField: UITextField) {
        validateLoginButton()
    }

    private func validateLoginButton() {
        let emailText = emailTFOutlet.text ?? ""
        let passwordText = passwordTFOutlet.text ?? ""

        // Disable the button if either field is empty
        let fieldsAreEmpty = emailText.isEmpty || passwordText.isEmpty
        LoginButtonOutlet.isEnabled = !fieldsAreEmpty
        LoginButtonOutlet.alpha = fieldsAreEmpty ? 0.8 : 1.0
    }

    // Setup keyboard notifications
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

    // Your existing methods ...
    func setupUI() {
        let buttons = [googleButtonOutlet, appleButtonOutlet]
        buttons.forEach {
            $0?.layer.cornerRadius = 15
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }

        let inputBoxes = [EmailInputBox, PasswordInputBox]
        inputBoxes.forEach {
            $0?.layer.cornerRadius = 15
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }

        // Initialize login button state
        validateLoginButton()
    }

    //MARK: To Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func togglePasswordVisibility(_ sender: Any) {
        passwordTFOutlet.isSecureTextEntry.toggle()

        let imageName = passwordTFOutlet.isSecureTextEntry ? "eye" : "eye.slash"
        togglePasswordOutlet.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func handleForgotPassword(_ sender: Any) {
    }

    //MARK: Login Button
    @IBAction func handleLogin(_ sender: Any) {
        guard let email = emailTFOutlet.text, let password = passwordTFOutlet.text,
              !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }

        showLoadingState(true)

        Task {
            do {
                let session = try await supabase.auth.signIn(email: email, password: password)

                let userID = session.user.id
                print("✅ User ID: \(userID)")

                try await fetchUserRole(userID: userID)

            } catch {
                await MainActor.run {
                    showLoadingState(false)
                    showAlert(title: "Error", message: error.localizedDescription)
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
            print(user)

            await MainActor.run {
                showLoadingState(false)
                transitionToHomeScreen(role: user.role)
                showAlert(title: "Success", message: "Login Successfully")
            }
        } catch {
            print("❌ Decoding Error: \(error.localizedDescription)")
            await MainActor.run {
                showLoadingState(false)
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

    //MARK: SignUp Button
    @IBAction func handleSignUp(_ sender: Any) {
    }

    @IBAction func handleLoginWithGoogle(_ sender: Any) {
    }

    @IBAction func handleLoginWithApple(_ sender: Any) {
    }

    func showAlert(title: String, message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: false)
    }

    func setupActivityIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .systemOrange
        LoginButtonOutlet.addSubview(loadingIndicator)

        // Center the indicator in the button
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: LoginButtonOutlet.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: LoginButtonOutlet.centerYAnchor)
        ])
    }

    func hideLoadingIndicator() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
    }

    func showLoadingState(_ isLoading: Bool) {
        if isLoading {
            LoginButtonOutlet.setTitle("", for: .normal) // Hide text
            loadingIndicator.startAnimating()
            LoginButtonOutlet.isEnabled = false
            LoginButtonOutlet.alpha = 0.6
        } else {
            LoginButtonOutlet.setTitle("Login", for: .normal) // Restore text
            loadingIndicator.stopAnimating()

            // Reset button state based on validation
            validateLoginButton()
        }
    }

    // Dismiss keyboard when tapping outside text fields
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Dismiss keyboard when "Return" is pressed
        return true
    }
}
