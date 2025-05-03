import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var NextButton: UIButton!

    @IBOutlet weak var TextFieldBox: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        validateNextButton()

        //Make Box for Text Field rounded
        TextFieldBox.layer.cornerRadius = 16
        TextFieldBox.layer.borderWidth = 1
        TextFieldBox.layer.borderColor = UIColor.systemGray.cgColor

        setupActivityIndicator()
        emailTextField.delegate = self // Set delegate for text field

        // Set up keyboard notifications
        setupKeyboardNotifications()
    }

    private func validateNextButton() {
        let email = emailTextField.text

        // Disable the button if either field is empty or email is invalid
        let fieldsAreEmpty = email?.isEmpty ?? true
        let isEmailValid = isValidEmail(email)
        NextButton.isEnabled = !fieldsAreEmpty && isEmailValid
        NextButton.alpha = (fieldsAreEmpty || !isEmailValid) ? 0.8 : 1.0
    }

    let loadingIndicator = UIActivityIndicatorView(style: .medium)

    @IBAction func sendResetEmail(_ sender: Any) {
        guard let email = emailTextField.text, isValidEmail(email) else {
            showAlert(message: "Please enter a valid email.")
            return
        }

        showLoadingState(true)

        Task {
            do {
                _ = try await supabase.auth.resetPasswordForEmail(email)

            } catch {
                await MainActor.run {
                    showLoadingState(false)
                    showAlert(message: "Failed to send reset email. Please try again.")
                }
                return
            }

            await MainActor.run {
                showLoadingState(false)
                showAlert(message: "Reset email sent successfully.") { [weak self] _ in
                    // Navigate back to the previous screen after the alert is dismissed
                    if let navigationController = self?.navigationController {
                        navigationController.popViewController(animated: true)
                    } else {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func setupActivityIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .systemOrange
        NextButton.addSubview(loadingIndicator)

        // Center the indicator in the button
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: NextButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: NextButton.centerYAnchor)
        ])
    }

    func hideLoadingIndicator() {
        self.view.subviews.forEach { $0.removeFromSuperview() }
    }

    func showLoadingState(_ isLoading: Bool) {
        if isLoading {
            NextButton.setTitle("", for: .normal) // Hide text
            loadingIndicator.startAnimating()
            NextButton.isEnabled = false
            NextButton.alpha = 0.6
        } else {
            NextButton.setTitle("Next", for: .normal) // Restore text
            loadingIndicator.stopAnimating()
            NextButton.isEnabled = true
            NextButton.alpha = 1.0
        }
    }

    func showAlert(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Forgot Password", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        present(alert, animated: true)
    }

    // Function to validate email format
    func isValidEmail(_ email: String?) -> Bool {
        guard let email = email, !email.isEmpty else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // Set up keyboard notifications
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
extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateNextButton()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }
}
