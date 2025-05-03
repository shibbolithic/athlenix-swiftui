import Supabase
import Foundation



func fetchUsers() {
        Task {
            do {
                let response = try await supabase.from("User").select("*").execute()
                //print(response)

                // Assuming response.data is of type Data
                let decoder = JSONDecoder()
                let users1 = try decoder.decode([Usertable].self, from: response.data)
                
                print(String(data: response.data, encoding: .utf8)!)
                
                // Handle the fetched users data
                print(users1)
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }

func fetchAthletes2() {
        Task {
            do {
                let response = try await supabase.from("AthleteProfile").select("*").execute()
                //print(response)

                // Assuming response.data is of type Data
                let decoder = JSONDecoder()
                let athlete101 = try decoder.decode([AthleteProfileTable].self, from: response.data)
                
                print(String(data: response.data, encoding: .utf8)!)
                
                // Handle the fetched users data
                print(athlete101)
                
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }

func fetchAthletes() {
    Task {
        do {
            let response = try await supabase.from("AthleteProfile").select("*").execute()
            let decoder = JSONDecoder()
            let athletes = try decoder.decode([AthleteProfile].self, from: response.data)
            print(athletes)
        } catch {
            print("Error fetching athlete profiles: \(error)")
        }
    }
}

func fetchTeams11() {
    Task {
        do {
            let response = try await supabase.from("teams").select("*").execute()
            let decoder = JSONDecoder()
            let teams = try decoder.decode([Teams].self, from: response.data)
            print(teams)
        } catch {
            print("Error fetching teams: \(error)")
        }
    }
}

import UIKit

func convertImageToData(image: UIImage) -> Data? {
    // Choose a compression format (JPEG is often a good balance)
    return image.jpegData(compressionQuality: 0.8) // Adjust quality as needed
    // or
    // return image.pngData() // For lossless compression (larger file size)
}

// Example usage:



//func insertUser(user: UserTable) {
//    Task {
//        do {
//            let response = try await supabase.from("User").insert([user]).execute()
//            guard let insertedUser = response.data as? [UserTable] else {
//                print("Error inserting user")
//                return
//            }
//            // Handle the inserted user data
//            print(insertedUser)
//        } catch {
//            print("Error inserting user: \(error)")
//        }
//    }
//}

//func updateUser(userID: UUID, updatedFields: [String: Any]) {
//    Task {
//        do {
//            let response = try await supabase.from("users").update(updatedFields).eq("userID", value: userID).execute()
//            guard let updatedUser = response.data as? [UserTable] else {
//                print("Error updating user")
//                return
//            }
//            // Handle the updated user data
//            print(updatedUser)
//        } catch {
//            print("Error updating user: \(error)")
//        }
//    }
//}

func deleteUser(userID: UUID) {
    Task {
        do {
            let response = try await supabase.from("User").delete().eq("userID", value: userID).execute()
            // Handle the deleted user data
            print(response)
        } catch {
            print("Error deleting user: \(error)")
        }
    }
}
