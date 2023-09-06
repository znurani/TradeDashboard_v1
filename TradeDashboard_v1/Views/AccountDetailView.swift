//
//  AccountDetailView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct AccountDetailView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    
    let accountNumber: String

    var body: some View {
        List {
            ForEach(accountManager.accountList.first(where: { $0.number == accountNumber })?.positions ?? [], id: \.id) { position in
                VStack(alignment: .leading) {
                    Text("Symbol: \(position.symbol)")
                        .font(.headline)
                    Text("Open Quantity: \(position.openQuantity)")
                        .font(.subheadline)
                    Text("Current Market Value: \(position.currentMarketValue)")
                        .font(.subheadline)
                    // Add other details as needed
                }
            }
        }
        .navigationTitle("Positions for \(accountNumber)")
        .onAppear {
            // If you want to fetch positions again when the view appears
            accountManager.fetchPositions(apiServer: authenticationManager.apiServer ?? "", accountId: accountNumber, accessToken: authenticationManager.accessToken ?? "" )
        }
    }
}


