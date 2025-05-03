////
////  ProfileDetailSelectionViewController.swift
////  PakhisAthlinix
////
////  Created by admin65 on 29/12/24.
////
//
//
//import UIKit
//
//class ViewProfileDetailSelectionViewController: UIViewController {
//    var options: [String] = []
//    var selectedOption: String?
//    var onSave: ((String) -> Void)?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        setupUI()
//    }
//    
//    func setupUI() {
//        let pickerView = UIPickerView()
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        pickerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(pickerView)
//        
//        NSLayoutConstraint.activate([
//            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        
//        let saveButton = UIButton()
//        saveButton.setTitle("Save", for: .normal)
//        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(saveButton)
//        
//        NSLayoutConstraint.activate([
//            saveButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
//            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
//    }
//    
//    @objc func saveButtonTapped() {
//        if let selectedOption = selectedOption {
//            onSave?(selectedOption)
//        }
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//extension ViewProfileDetailSelectionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        options.count
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        options[row]
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedOption = options[row]
//    }
//}
