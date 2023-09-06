//
//  AuthenticationManager.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//  Updated by Zeshan Nurani on 2023-09-03.
//
//  This class manages authentication tokens, facilitates token refresh,
//  and handles token expiration countdown. It interacts with a REST API
//  for token renewal, updates token-related properties, and initiates timers
//  for refreshing tokens and tracking expiration. Designed for use in the
//  TradeDashboard_v1 app, this class ensures secure and efficient handling
//  of user authentication.
//
//  Usage:
//  - Initialize an instance of `AuthenticationManager`.
//  - Call `postRequest()` to refresh the access token using the refresh token.
//  - Automatic timers handle token refresh and countdown.
//  - Use `logout()` to log out the user, invalidate timers, and clear properties.
//

import Foundation
import Combine

class AuthenticationManager: ObservableObject {
    
    // Published properties that hold authentication-related information
    @Published var response: String?
    @Published var refreshToken: String = ""
    @Published var accessToken: String?
    @Published var apiServer: String?
    @Published var expiresIn: Int?
    @Published var tokenType: String?
    @Published var tokenValid: Bool = false
    @Published var errorOccured: Bool = false
    @Published var errorMessage: String = ""
    
    // Set to keep track of subscriptions to Combine publishers
    private var subscriptions = Set<AnyCancellable>()
    
    // Timers to manage token refresh and countdown
    private var refreshTimer: Timer?
    private var countdownTimer: Timer?
    
    // Initializer sets up the timers
    init() {
        startTimer()
    }
    
    // Codable struct to match the response from the API
    struct Response: Codable {
        let access_token: String
        let token_type: String
        let expires_in: Int
        let refresh_token: String
        let api_server: String
    }
    
    // Function to send a POST request for token refresh
    func postRequest() {
        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        
        let url = URL(string: "https://login.questrade.com/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTaskPublisher(for: request)
            // Use tryMap to validate the HTTP response status code
            .tryMap { output in
                guard let httpResponse = output.response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLSession.DataTaskPublisher.Failure.self as! Error
                }
                return output.data
            }
            // Decode the JSON response and update properties on the main queue
            .decode(type: Response.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.tokenValid = false
                    self?.errorOccured = true
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.accessToken = response.access_token
                self?.apiServer = response.api_server
                self?.refreshToken = response.refresh_token
                self?.expiresIn = response.expires_in
                self?.tokenType = response.token_type
                self?.tokenValid = true
                self?.errorOccured = false
                self?.startTimer()
            }
            .store(in: &subscriptions)
    }
    
    // Function to start the refresh and countdown timers
    private func startTimer() {
        refreshTimer?.invalidate()
        countdownTimer?.invalidate()
        
        guard let expiresIn = expiresIn else { return }
        
        // Refresh when 95% of the token life remains
        let refreshTime = Double(expiresIn) * 0.95
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshTime, repeats: false) { [weak self] _ in
            self?.postRequest()
        }
        
        // Create a timer to decrement expiresIn every second
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if let expiresIn = self?.expiresIn, expiresIn > 0 {
                self?.expiresIn = expiresIn - 1
            } else {
                self?.countdownTimer?.invalidate()
            }
        }
    }
    
    // Function to log out and invalidate timers
    func logout() {
        refreshTimer?.invalidate()
        countdownTimer?.invalidate()
        refreshToken = ""
        accessToken = nil
        expiresIn = nil
        tokenValid = false
    }
}
