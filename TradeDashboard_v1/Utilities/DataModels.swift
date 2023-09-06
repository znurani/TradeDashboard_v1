
import Foundation

// Struct to hold account details
struct Account: Decodable, Identifiable {
    var id = UUID()
    let type: String
    let number: String
    let status: String
    let isPrimary: Bool
    let isBilling: Bool
    let clientAccountType: String
    var positions: [Position]?
    var balances: [Balance]?
    var executions: [Execution]?
    
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

struct AccountsResponse: Decodable {
    let accounts: [Account]
    let userId: Int
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

// Struct to hold API response for positions
struct PositionsResponse: Decodable {
    let positions: [Position]
}
    
struct Balance: Decodable, Identifiable {
    
    var id = UUID()
    var currency: String
    var cash: Double
    var marketValue: Double
    var totalEquity: Double
    var buyingPower: Double
    var maintenanceExcess: Double
    var isRealTime: Bool
    var type: BalanceType?
    
    enum CodingKeys: String, CodingKey {
        case currency, cash, marketValue, totalEquity, buyingPower, maintenanceExcess, isRealTime
    }
    
    enum BalanceType: String, Decodable {
        case perCurrency
        case combined
        case sodPerCurrency
        case sodCombined
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(String.self, forKey: .currency)
        cash = try container.decode(Double.self, forKey: .cash)
        marketValue = try container.decode(Double.self, forKey: .marketValue)
        totalEquity = try container.decode(Double.self, forKey: .totalEquity)
        buyingPower = try container.decode(Double.self, forKey: .buyingPower)
        maintenanceExcess = try container.decode(Double.self, forKey: .maintenanceExcess)
        isRealTime = try container.decode(Bool.self, forKey: .isRealTime)
        
    }
}

struct BalancesResponse: Decodable {
    let perCurrencyBalances: [Balance]
    let combinedBalances: [Balance]
    let sodPerCurrencyBalances: [Balance]
    let sodCombinedBalances: [Balance]
}


struct Execution: Decodable, Identifiable {
    
    var id = UUID()
    var symbol: String
    var symbolId: Int
    var quantity: Int
    var side: String
    var price: Double
    var orderId: Int
    var orderChainId: Int
    var exchangeExecId: String
    var timestamp: Date
    var notes: String
    var venue: String
    var totalCost: Double
    var orderPlacementCommission: Double
    var commission: Double
    var executionFee: Double
    var secFee: Double
    var canadianExecutionFee: Int
    var parentId: Int
    
    enum CodingKeys: String, CodingKey {
        case symbol, symbolId, quantity, side, price, orderId, orderChainId, exchangeExecId, timestamp, notes, venue, totalCost, orderPlacementCommission, commission, executionFee, secFee, canadianExecutionFee, parentId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        symbolId = try container.decode(Int.self, forKey: .symbolId)
        quantity = try container.decode(Int.self, forKey: .quantity)
        side = try container.decode(String.self, forKey: .side)
        price = try container.decode(Double.self, forKey: .price)
        orderId = try container.decode(Int.self, forKey: .orderId)
        orderChainId = try container.decode(Int.self, forKey: .orderChainId)
        exchangeExecId = try container.decode(String.self, forKey: .exchangeExecId)
        
        // Decode date from string
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = dateFormatter.date(from: timestampString) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        
        timestamp = date
        
        notes = try container.decode(String.self, forKey: .notes)
        venue = try container.decode(String.self, forKey: .venue)
        totalCost = try container.decode(Double.self, forKey: .totalCost)
        orderPlacementCommission = try container.decode(Double.self, forKey: .orderPlacementCommission)
        commission = try container.decode(Double.self, forKey: .commission)
        executionFee = try container.decode(Double.self, forKey: .executionFee)
        secFee = try container.decode(Double.self, forKey: .secFee)
        canadianExecutionFee = try container.decode(Int.self, forKey: .canadianExecutionFee)
        parentId = try container.decode(Int.self, forKey: .parentId)
    }
}

// Represents the response for all executions
struct ExecutionsResponse: Decodable {
    var executions: [Execution]
}

// Represents the response for the server time
struct TimeResponse: Decodable {
    let time: String
}




