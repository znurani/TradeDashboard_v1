import Foundation
import Combine

class AccountManager: ObservableObject {
    
    @Published var accountList: [Account] = []
    private var cancellables = Set<AnyCancellable>()

    
    func fetchAccounts(apiServer: String, accessToken: String, completion: @escaping () -> Void) {
        let url = URL(string: "\(apiServer)v1/accounts")!
        let headers = ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]
        
        NetworkManager.performRequest(url: url, headers: headers, decodingType: AccountsResponse.self, callingFunction: "Accounts")
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
                completion()
            })
            .store(in: &cancellables)
    }
    
    func fetchPositions(apiServer: String, accountId: String, accessToken: String) {
        let url = URL(string: "\(apiServer)v1/accounts/\(accountId)/positions")!
        let headers = ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]
        
        NetworkManager.performRequest(url: url, headers: headers, decodingType: PositionsResponse.self, callingFunction: "Positions")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Fetching positions failed: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                if let index = self?.accountList.firstIndex(where: { $0.number == accountId }) {
                    self?.accountList[index].positions = response.positions
                    
                    print("Retrieved Positions for: \(accountId)")
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchBalances(apiServer: String, accountId: String, accessToken: String) {
        let url = URL(string: "\(apiServer)v1/accounts/\(accountId)/balances")!
        let headers = ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]
        
        NetworkManager.performRequest(url: url, headers: headers, decodingType: BalancesResponse.self, callingFunction: "Balances")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Fetching balances failed: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                var allBalances: [Balance] = []
                
                let updateBalancesWithType = { (balances: [Balance], type: Balance.BalanceType) -> [Balance] in
                    return balances.map {
                        var balance = $0
                        balance.type = type
                        return balance
                    }
                }
                
                allBalances += updateBalancesWithType(response.perCurrencyBalances, .perCurrency)
                allBalances += updateBalancesWithType(response.combinedBalances, .combined)
                allBalances += updateBalancesWithType(response.sodPerCurrencyBalances, .sodPerCurrency)
                allBalances += updateBalancesWithType(response.sodCombinedBalances, .sodCombined)
                
                print("Retrieved Balances for: \(accountId)")
                
                if let index = self?.accountList.firstIndex(where: { $0.number == accountId }) {
                    self?.accountList[index].balances = allBalances
                }
            })
            .store(in: &cancellables)
    }
    
    
    func fetchExecutions(apiServer: String, accountId: String, accessToken: String) {
        print("[DEBUG] Starting: fetchExecutions")
        
        // Fetch executions based on phone's local time
        fetchExecutionsBasedOnLocalTime(apiServer: apiServer, accountId: accountId, accessToken: accessToken)
    }


    private func fetchServerTime(apiServer: String, accessToken: String, completion: @escaping (Result<Date, Error>) -> Void) {
        let url = URL(string: "\(apiServer)v1/time")!
        let headers = ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]
        
        NetworkManager.performRequest(url: url, headers: headers, decodingType: TimeResponse.self, callingFunction: "fetchServerTime")
            .sink(receiveCompletion: { _ in }, receiveValue: { timeResponse in
                print("[DEBUG] Received time string: \(timeResponse.time)")
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let date = dateFormatter.date(from: timeResponse.time) {
                    print("[DEBUG] Successfully parsed date: \(date)")
                    completion(.success(date))
                } else {
                    print("[ERROR] Date parsing failed")
                    completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                }
            })
            .store(in: &cancellables)
    }

    private func fetchExecutionsBasedOnServerTime(apiServer: String, accountId: String, accessToken: String, serverTime: Date) {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startTime = Calendar.current.date(byAdding: .day, value: -7, to: serverTime)!
        let startTimeString = dateFormatter.string(from: startTime)
        let endTimeString = dateFormatter.string(from: serverTime)
        
        let url = URL(string: "\(apiServer)v1/accounts/\(accountId)/executions?startTime=\(startTimeString)&endTime=\(endTimeString)")!
        let headers = ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]

        NetworkManager.performRequest(url: url, headers: headers, decodingType: ExecutionsResponse.self, callingFunction: "fetchExecutionsBasedOnServerTime")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("[ERROR] Fetching executions failed: \(error)")
                case .finished:
                    print("[DEBUG] Finished: fetchExecutions")
                }
            }, receiveValue: { [weak self] response in
                if let index = self?.accountList.firstIndex(where: { $0.number == accountId }) {
                    self?.accountList[index].executions = response.executions
                    print("[DEBUG] Updated executions for the last 7 days for: \(accountId)")
                }
            })
            .store(in: &cancellables)
    }
    
    private func fetchExecutionsBasedOnLocalTime(apiServer: String, accountId: String, accessToken: String) {
        // Get current time from the phone
        let localTime = Date()
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Calculate start and end times
        let startTime = Calendar.current.date(byAdding: .day, value: -7, to: localTime)!
        let startTimeString = dateFormatter.string(from: startTime)
        let endTimeString = dateFormatter.string(from: localTime)
        
        let url = URL(string: "\(apiServer)v1/accounts/\(accountId)/executions?startTime=\(startTimeString)&endTime=\(endTimeString)")!
        let headers = ["Authorization": "Bearer \(accessToken)", "Accept": "application/json"]
        
        NetworkManager.performRequest(url: url, headers: headers, decodingType: ExecutionsResponse.self, callingFunction: "fetchExecutionsBasedOnLocalTime")
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("[ERROR] Fetching executions failed: \(error)")
                case .finished:
                    print("[DEBUG] Finished: fetchExecutionsBasedOnLocalTime")
                }
            }, receiveValue: { [weak self] response in
                if let index = self?.accountList.firstIndex(where: { $0.number == accountId }) {
                    self?.accountList[index].executions = response.executions
                    print("[DEBUG] Updated executions for the last 7 days for: \(accountId)")
                }
            })
            .store(in: &cancellables)
    }


    class NetworkManager {
        
        static func performRequest<T: Decodable>(url: URL, headers: [String: String], decodingType: T.Type, callingFunction: String = "") -> AnyPublisher<T, Error> {
            var request = URLRequest(url: url)
            headers.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
            print("Request Sent from \(callingFunction)")
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }

    
    
    
}

