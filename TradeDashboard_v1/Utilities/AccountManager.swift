//
//  AccountManager.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-09-03.
//  Updated by Zeshan Nurani on 2023-09-0X. 
//
//  This code is written in Swift and uses the Combine framework to handle asynchronous tasks. It defines a class AccountManager that fetches account and position data from an API and
//  stores it in an array of AccountDetails and Position structs.
//

import Foundation
import Combine

// AccountManager class that conforms to ObservableObject protocol
class AccountManager: ObservableObject {
    
    // Published property that will notify subscribers about changes
    @Published var accountList: [AccountDetails] = []
    
    // Set to store any cancellable instances
    private var cancellables = Set<AnyCancellable>()
    
    // Struct to hold account details
    struct AccountDetails: Decodable, Identifiable {
        var id = UUID()
        let type: String
        let number: String
        let status: String
        let isPrimary: Bool
        let isBilling: Bool
        let clientAccountType: String
        var positions: [Position]?
        
        // CodingKeys enum to map JSON keys to Swift properties
        enum CodingKeys: String, CodingKey {
            case type, number, status, isPrimary, isBilling, clientAccountType
        }
        
        // Custom initializer to decode JSON data
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            type = try container.decode(String.self, forKey: .type)
            number = try container.decode(String.self, forKey: .number)
            status = try container.decode(String.self, forKey: .status)
            isPrimary = try container.decode(Bool.self, forKey: .isPrimary)
            isBilling = try container.decode(Bool.self, forKey: .isBilling)
            clientAccountType = try container.decode(String.self, forKey: .clientAccountType)
        }
    }

    // Struct to hold position details
    struct Position: Decodable, Identifiable {
        
        var id = UUID()
        var symbol: String
        var symbolId: Int
        var openQuantity: Double
        var currentMarketValue: Double
        var currentPrice: Double
        var averageEntryPrice: Double
        var closedPnl: Double
        var openPnl: Double?
        var totalCost: Double
        var isRealTime: Bool
        var isUnderReorg: Bool
        
        // CodingKeys enum to map JSON keys to Swift properties
        enum CodingKeys: String, CodingKey {
            case symbol, symbolId, openQuantity, currentMarketValue, currentPrice, averageEntryPrice, closedPnl, openPnl, totalCost, isRealTime, isUnderReorg
        }
        
        // Custom initializer to decode JSON data
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            symbol = try container.decode(String.self, forKey: .symbol)
            symbolId = try container.decode(Int.self, forKey: .symbolId)
            openQuantity = try container.decode(Double.self, forKey: .openQuantity)
            currentMarketValue = try container.decode(Double.self, forKey: .currentMarketValue)
            currentPrice = try container.decode(Double.self, forKey: .currentPrice)
            averageEntryPrice = try container.decode(Double.self, forKey: .averageEntryPrice)
            closedPnl = try container.decode(Double.self, forKey: .closedPnl)
            openPnl = try container.decode(Double.self, forKey: .openPnl)
            totalCost = try container.decode(Double.self, forKey: .totalCost)
            isRealTime = try container.decode(Bool.self, forKey: .isRealTime)
            isUnderReorg = try container.decode(Bool.self, forKey: .isUnderReorg)
        }
    }

    
    struct Order {
        // ... (same as before)
    }
    
    struct Balances {
        // ... (same as before)
    }
    
    struct AccountsResponse: Decodable {
        let accounts: [AccountDetails]
        let userId: Int
    }
    
    
    // Function to fetch accounts from API
    func fetchAccounts(apiServer: String, accessToken: String) {
        let url = URL(string: "\(apiServer)v1/accounts")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Using Combine to handle asynchronous network request
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AccountsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Fetching accounts failed: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                print("Received accounts: \(response.accounts.count)")
                self?.accountList = response.accounts
            })
            .store(in: &cancellables)
    }
    
    // Function to fetch positions for a specific account from API
    func fetchPositions(apiServer: String, accountId: String, accessToken: String) {
        
        let url = URL(string: "\(apiServer)v1/accounts/\(accountId)/positions")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Using Combine to handle asynchronous network request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                try JSONDecoder().decode([String: [Position]].self, from: data)["positions"] ?? []
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Fetching positions failed: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] positions in
                if let index = self?.accountList.firstIndex(where: { $0.number == accountId }) {
                    self?.accountList[index].positions = positions
                }
            })
            .store(in: &cancellables)
    }
}

