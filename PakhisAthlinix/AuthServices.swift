

import Supabase

class AuthServices {
    static let shared = AuthServices()
    
    
    //Register the user
    func signUp(email: String, password: String, fullName: String) async throws-> User{
        let auth = try await supabase.auth.signUp(email: email, password: password, data: ["display_name": .string(fullName)] )
        return auth.user
    }
    
    
    //Login the user
    func signIn(email: String, password: String) async throws -> User{
        let auth = try await supabase.auth.signIn(email: email, password: password)
        return auth.user
    }
    
    
    //signout the user
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    var currentUser: User? {
        supabase.auth.currentSession?.user
    }
    
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    func fetchSession() async throws -> User? {
        do {
            // Get the current session state
            let session = try await supabase.auth.session
            
            // If no session exists, return nil
                if session.isExpired {
                return nil
            }
            
            
            // Try to refresh the session
            let refreshedSession = try await supabase.auth.refreshSession()
            return refreshedSession.user
            
        } catch {
            print("Error fetching session, didnt return any user")
            throw error
        }
    }
    
    
    func checkSession() async throws -> User? {
        do {
            // Get the current session state
            let session = try await supabase.auth.session
            
            // If no session exists, return nil
                if session.isExpired {
                return nil
            }
            
            
            // Try to refresh the session
            let refreshedSession = try await supabase.auth.refreshSession()
            return refreshedSession.user
            
        } catch {
            // If refresh fails, clear the session
            try? await signOut()
            throw error
        }
    }
    
    
}
