import SwiftUI

struct AccountDetailView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    
    let accountNumber: String
    
    var body: some View {
        List {
            // Display positions
            Section(header: Text("Positions")) {
                ForEach(accountManager.accountList.first(where: { $0.number == accountNumber })?.positions ?? [], id: \.id) { position in
                    VStack(alignment: .leading) {
                        Text("Symbol: \(position.symbol)")
                            .font(.headline)
                        Text("Symbol ID: \(position.symbolId)")
                            .font(.subheadline)
                        Text("Open Quantity: \(position.openQuantity)")
                            .font(.subheadline)
                        Text("Current Market Value: \(position.currentMarketValue)")
                            .font(.subheadline)
                        Text("Current Price: \(position.currentPrice)")
                            .font(.subheadline)
                        Text("Average Entry Price: \(position.averageEntryPrice)")
                            .font(.subheadline)
                        Text("Closed PnL: \(position.closedPnl)")
                            .font(.subheadline)
                        Text("Open PnL: \(position.openPnl ?? 0)")
                            .font(.subheadline)
                        Text("Total Cost: \(position.totalCost)")
                            .font(.subheadline)

                    }
                }
            }
            
            // Display balances
            Section(header: Text("Balances")) {
                ForEach(accountManager.accountList.first(where: { $0.number == accountNumber })?.balances ?? [], id: \.id) { balance in
                    VStack(alignment: .leading) {
                        Text("Currency: \(balance.currency)")
                            .font(.headline)
                        Text("Cash: \(balance.cash)")
                            .font(.subheadline)
                        Text("Market Value: \(balance.marketValue)")
                            .font(.subheadline)
                        Text("Total Equity: \(balance.totalEquity)")
                            .font(.subheadline)
                        Text("Buying Power: \(balance.buyingPower)")
                            .font(.subheadline)
                        Text("Maintenance Excess: \(balance.maintenanceExcess)")
                            .font(.subheadline)
                        Text("Type: \(balance.type?.rawValue ?? "Unknown")") // Handle the optional type here
                            .font(.subheadline)
                    }
                }
            }
            
            Section(header: Text("Executions")) {
                ForEach(accountManager.accountList.first(where: { $0.number == accountNumber })?.executions ?? [], id: \.id) { execution in
                    VStack(alignment: .leading) {
                        Text("Symbol: \(execution.symbol)")
                            .font(.headline)
                        Text("Quantity: \(execution.quantity)")
                            .font(.subheadline)
                        Text("Price: \(execution.price, specifier: "%.2f")")
                            .font(.subheadline)
                        Text("Side: \(execution.side)")
                            .font(.subheadline)
                        Text("Venue: \(execution.venue)")
                            .font(.subheadline)
                        Text("Total Cost: \(execution.totalCost, specifier: "%.2f")")
                            .font(.subheadline)
                        Text("Commission: \(execution.commission, specifier: "%.2f")")
                            .font(.subheadline)
                        Text("Timestamp: \(execution.timestamp, formatter: DateFormatter())") // Use a proper DateFormatter
                            .font(.subheadline)
                        Text("Execution Fee: \(execution.executionFee, specifier: "%.2f")")
                            .font(.subheadline)
                        Text("SEC Fee: \(execution.secFee, specifier: "%.2f")")
                            .font(.subheadline)
                        Text("Canadian Execution Fee: \(execution.canadianExecutionFee)")
                            .font(.subheadline)
                        Text("Parent ID: \(execution.parentId)")
                            .font(.subheadline)
                        Text("Order ID: \(execution.orderId)")
                            .font(.subheadline)
                        Text("Order Chain ID: \(execution.orderChainId)")
                            .font(.subheadline)
                        Text("Exchange Exec ID: \(execution.exchangeExecId)")
                            .font(.subheadline)
                        Text("Notes: \(execution.notes)")
                            .font(.subheadline)
                    }
                }
            }

        }
        .onAppear {
            // Fetch the positions and balances when the view appears
            accountManager.fetchPositions(apiServer: authenticationManager.apiServer ?? "", accountId: accountNumber, accessToken: authenticationManager.accessToken ?? "")
            accountManager.fetchBalances(apiServer: authenticationManager.apiServer ?? "", accountId: accountNumber, accessToken: authenticationManager.accessToken ?? "")
            accountManager.fetchExecutions(apiServer: authenticationManager.apiServer ?? "", accountId: accountNumber, accessToken: authenticationManager.accessToken ?? "")

        }
        .navigationTitle("Account Details")
    }
}
