////
////  SupabaseEditManager.swift
////  PakhisAthlinix
////
////  Created by admin65 on 29/12/24.
////
//
//func updateUserDetails(userID: String, details: AthleteProfile?) async throws {
//    guard let details = details else { return }
//    
//    let updateQuery = """
//    UPDATE profiles
//    SET position = '\(details.position)',
//        height = \(details.height),
//        weight = \(details.weight)
//    WHERE id = '\(userID)';
//    """
//    
//    try await supabase.shared.executeQuery(query: updateQuery)
//}
//
//func showSelectionModal(for type: String) {
//    let selectionVC = ProfileDetailSelectionViewController()
//    switch type {
//    case "Position":
//        selectionVC.options = positions.allCases.map { $0.rawValue }
//    case "Height":
//        selectionVC.options = heightRange.map { "\($0) cm" }
//    case "Weight":
//        selectionVC.options = weightRange.map { "\($0) kg" }
//    default: return
//    }
//    
//    selectionVC.onSave = { [weak self] selectedValue in
//        self?.saveDetail(type: type, value: selectedValue)
//    }
//    present(selectionVC, animated: true, completion: nil)
//}
//
//    
//    @objc func saveButtonTapped() {
//        if let selectedOption = selectedOption {
//            onSave?(selectedOption)
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//
//func saveDetail(type: String, value: String) {
//    Task {
//        guard let user11 = user11 else { return }
//        var updatedFields: [String: Any] = [:]
//
//        // Update the athlete profile based on the selected type
//        switch type {
//        case "Position":
//            athleteProfile?.position = value
//            if let position = athleteProfile?.position {
//                updatedFields["position"] = position
//            
//                try await supabase.from("athleteProfile").update("position").eq("userID", value: user11.userID)..execute()
//        case "Height":
//            if let heightInCm = Double(value.replacingOccurrences(of: " cm", with: "")) {
//                athleteProfile?.height = Double(Float(heightInCm))  // Convert to Float
//            }
//        case "Weight":
//            if let weightInKg = Double(value.replacingOccurrences(of: " kg", with: "")) {
//                athleteProfile?.weight = Double(Float(weightInKg))  // Convert to Float
//            }
//        default: return
//        }
//        
//        // Prepare the data for update
//       // var updatedFields: [String: Any] = [:]
//        if let position = athleteProfile?.position {
//            updatedFields["position"] = position
//        }
//        if let height = athleteProfile?.height {
//            updatedFields["height"] = height
//        }
//        if let weight = athleteProfile?.weight {
//            updatedFields["weight"] = weight
//        }
//
//        // Update the data in Supabase using the latest API
//        do {
//            let response = try await supabase
//                .from("athleteProfile") // Replace with your actual table name
//                .update(updatedFields)
//                .eq("userID", value: user11.userID) // Assuming `user_id` is the column that identifies the athlete
//                .execute()
//            
//            if response.error == nil {
//                print("\(type) updated successfully!")
//            } else {
//                print("Failed to update \(type): \(response.error?.message ?? "Unknown error")")
//            }
//        } catch {
//            print("Error updating \(type): \(error.localizedDescription)")
//        }
//    }
//}
//
//
//func setupTapGestures() {
//    let positionTap = UITapGestureRecognizer(target: self, action: #selector(handlePositionTap))
//    position.addGestureRecognizer(positionTap)
//    position.isUserInteractionEnabled = true
//
//    let heightTap = UITapGestureRecognizer(target: self, action: #selector(handleHeightTap))
//    height.addGestureRecognizer(heightTap)
//    height.isUserInteractionEnabled = true
//
//    let weightTap = UITapGestureRecognizer(target: self, action: #selector(handleWeightTap))
//    weight.addGestureRecognizer(weightTap)
//    weight.isUserInteractionEnabled = true
//}
//
//@objc func handlePositionTap() { showSelectionModal(for: "Position") }
//@objc func handleHeightTap() { showSelectionModal(for: "Height") }
//@objc func handleWeightTap() { showSelectionModal(for: "Weight") }
