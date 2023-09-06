//
//  AuthenticationManager.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.


import Foundation
import Combine
import Security

class AuthenticationManager: ObservableObject {
    
    @Published var accessToken: String?
    @Published var tokenType: String?
    @Published var expiresIn: Int?
    @Published var refreshToken: String = ""
    @Published var apiServer: String?
   
    @Published var tokenValid: Bool = false
    @Published var errorOccured: Bool = false
    @Published var errorMessage: String = ""
    
    private var subscriptions = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private var countdownTimer: Timer?
    private var isRefreshingToken = false
    
    init() {
        if let savedToken = retrieveFromKeychain(key: "refreshToken") {
            self.refreshToken = savedToken
            print("Debug: Initialized with saved refresh token: \(savedToken)") // Added debug
            self.postRequest()  // Validate the token on initialization

            if !self.loadFromJSON() {
                print("Debug: No JSON file found, or load failed.")
            }
            
            if !self.printJSONFileContent() {
                print("Debug: Could not print JSON content.")
            }
        }
    }

    
    struct AuthenticationData: Codable {
        var accessToken: String?
        var tokenType: String?
        var expiresIn: Int?
        var refreshToken: String
        var apiServer: String?
        
    }
    
    func prepareRequest() -> URLRequest? {
        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        
        guard let url = URL(string: "https://login.questrade.com/oauth2/token") else {
            print("Debug: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
        
        return request
    }

    func processResponse(_ output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            print("Debug: Not an HTTP response")
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Debug: Bad status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        return output.data
    }

    func updateState(_ response: Response) {
        print("Debug: Received value: \(response)")
        self.startTimer()
        self.accessToken = response.access_token
        self.tokenType = response.token_type
        self.expiresIn = response.expires_in
        self.refreshToken = response.refresh_token
        self.apiServer = response.api_server
        
        self.tokenValid = true
        self.errorOccured = false
        
        self.saveToKeychain(key: "refreshToken", value: response.refresh_token)
        
        self.saveToJSON()
        
        self.printJSONFileContent()
    }

    func postRequest() {
        if isRefreshingToken { return }
        isRefreshingToken = true

        print("Debug: postRequest() called with refreshToken: \(refreshToken)") // Added debug

        guard let request = prepareRequest() else { return }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(processResponse)
            .decode(type: Response.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isRefreshingToken = false // Reset the flag
                switch completion {
                case .failure(let error):
                    print("Debug: Sink received error: \(error)")
                    self?.tokenValid = false
                    self?.errorOccured = true
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    print("Debug: Sink finished successfully")
                }
            } receiveValue: { [weak self] response in
                self?.updateState(response)
            }
            .store(in: &subscriptions)
    }
    
    struct Response: Codable {
        let access_token: String
        let token_type: String
        let expires_in: Int
        let refresh_token: String
        let api_server: String
    }

    
    private func startTimer() {
        refreshTimer?.invalidate()
        countdownTimer?.invalidate()
        
        guard let expiresIn = expiresIn, expiresIn > 0 else { return }
        
        let refreshTime = Double(expiresIn) * 0.95
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshTime, repeats: false) { [weak self] _ in
            self?.postRequest()
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if let expiresIn = self?.expiresIn, expiresIn > 0 {
                self?.expiresIn = expiresIn - 1
            } else {
                self?.countdownTimer?.invalidate()
            }
        }
    }
    
    func logout() {
        refreshTimer?.invalidate()
        countdownTimer?.invalidate()
        accessToken = nil
        tokenType = nil
        expiresIn = nil
        refreshToken = ""
        deleteFromKeychain(key: "refreshToken")
        tokenValid = false
    }
}

extension AuthenticationManager {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    
    func saveToJSON() {
        let encoder = JSONEncoder()
        let authenticationData = AuthenticationData(accessToken: self.accessToken, tokenType: self.tokenType, expiresIn: self.expiresIn, refreshToken: self.refreshToken, apiServer: self.apiServer)
        
        do {
            let data = try encoder.encode(authenticationData)
            if let json = String(data: data, encoding: .utf8) {
                let filePath = getDocumentsDirectory().appendingPathComponent("authentication.json")
                try json.write(to: filePath, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Save to JSON failed: \(error)")
        }
    }

    func loadFromJSON() -> Bool {
        let filePath = getDocumentsDirectory().appendingPathComponent("authentication.json")
        do {
            let data = try Data(contentsOf: filePath)
            let decoded = try JSONDecoder().decode(AuthenticationData.self, from: data)
            
            self.accessToken = decoded.accessToken
            self.refreshToken = decoded.refreshToken
            // ... other properties
            
            return true
            
        } catch {
            print("Load from JSON failed: \(error)")
            return false
        }
    }

    func printJSONFileContent() -> Bool {
        let filePath = getDocumentsDirectory().appendingPathComponent("authentication.json")
        do {
            let data = try Data(contentsOf: filePath)
            if let json = String(data: data, encoding: .utf8) {
                print("JSON Content: \(json)")
                return true
            }
            return false
        } catch {
            print("Failed to read JSON file: \(error)")
            return false
        }
    }


    
}

extension AuthenticationManager{
    
    // Save key-value pair to Keychain
    func saveToKeychain(key: String, value: String) -> Bool {
        guard let valueData = value.data(using: .utf8) else {
            print("Debug: Value encoding to Data failed.")
            return false
        }
        
        // Delete any existing item with the same key
        deleteFromKeychain(key: key)
        
        // Prepare the query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: valueData
        ]
        
        // Add to Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        let success = (status == errSecSuccess)
        print("Debug: Saving \(key) to Keychain: \(success ? "Success" : "Failure")")
        return success
    }
    
    // Retrieve value for a key from Keychain
    func retrieveFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        
        var retrievedData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &retrievedData)
        
        if status == errSecSuccess {
            if let data = retrievedData as? Data,
               let value = String(data: data, encoding: .utf8) {
                print("Debug: Retrieved \(key) from Keychain: \(value)")
                return value
            }
        }
        print("Debug: Retrieval from Keychain failed for key: \(key)")
        return nil
    }
    
    // Delete key-value pair from Keychain
    func deleteFromKeychain(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        let success = (status == errSecSuccess)
        print("Debug: Deleting \(key) from Keychain: \(success ? "Success" : "Failure")")
        return success
    }
}
