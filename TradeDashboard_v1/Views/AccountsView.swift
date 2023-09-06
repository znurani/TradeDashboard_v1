//
//  MainView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct AccountsView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    
    @State private var searchText: String = ""  // Define searchText
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accountManager.accountList, id: \.id) { accountDetail in  // Loop through accountList
                    NavigationLink(destination: AccountDetailView(accountNumber: accountDetail.number)) {
                        VStack(alignment: .leading) {
                            Text("Account Type: \(accountDetail.type)")  // Correctly access type
                                .font(.headline)
                            Text("Account Number: \(accountDetail.number)")  // Correctly access number
                                .font(.headline)
                        }
                    }
                }
                .onDelete(perform: removeAccount)  // Moved onDelete here
            }
            .searchable(text: $searchText)
            .navigationTitle("Accounts")
            .navigationBarItems(trailing:
                                    Button(action: {
                accountManager.fetchAccounts(apiServer: authenticationManager.apiServer ?? "", accessToken: authenticationManager.accessToken ?? "")
            }) {
                Image(systemName: "arrow.clockwise")
            }
            )
        }.onAppear {
            // Fetch the accounts automatically when the view appears
            accountManager.fetchAccounts(apiServer: authenticationManager.apiServer ?? "", accessToken: authenticationManager.accessToken ?? "")
        }
    }
    
    func removeAccount(at offsets: IndexSet) {
        accountManager.accountList.remove(atOffsets: offsets)
    }
}


#Preview {
    AccountsView()
        .environmentObject(AccountManager())
        .environmentObject(AuthenticationManager())

}








/*struct AccountListView: View {
    // Create an instance of AccountManager as an ObservableObject
    @ObservedObject var accountManager = AccountManager()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accountManager.accountList) { account in
                    NavigationLink(destination: AccountDetailView(account: account)) {
                        Text("\(account.type) (\(account.number))")
                    }
                }
            }
            .navigationBarTitle("Accounts")
            .onAppear() {
                // Here, call the fetchAccounts function from the AccountManager
                // For demonstration, using placeholder API server and access token
                accountManager.fetchAccounts(apiServer: "https://api.example.com/", accessToken: "your_access_token_here")
            }
        }
    }
}*/

// This view displays details for a single account
/*struct AccountDetailView: View {
    var account: AccountManager.AccountDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Account Type: \(account.type)")
            Text("Account Number: \(account.number)")
            Text("Status: \(account.status)")
            Text("Is Primary: \(account.isPrimary ? "Yes" : "No")")
            Text("Is Billing: \(account.isBilling ? "Yes" : "No")")
            Text("Client Account Type: \(account.clientAccountType)")
            if let positions = account.positions {
                Text("Positions:")
                ForEach(positions) { position in
                    Text("Symbol: \(position.symbol), Quantity: \(position.openQuantity)")
                }
            }
        }
        .padding()
        .navigationBarTitle("Account Details", displayMode: .inline)
    }
}*/

/*struct AccountsView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    

}*/

/*struct AccountsView: View {
 
 @EnvironmentObject var accountManager: AccountManager
 @EnvironmentObject var authenticationManager: AuthenticationManager
 
 @State private var searchText: String = ""
 
 var body: some View {
     NavigationView {
         List {
             ForEach(accountManager.accountList, id: \.id) { accountDetail in
                 NavigationLink(destination: AccountDetailView(accountNumber: accountDetail.number)) {
                     VStack(alignment: .leading) {
                         Text("Account Type: \(accountDetail.type)")
                             .font(.headline)
                         Text("Account Number: \(accountDetail.number)")
                             .font(.headline)
                     }
                 }
             }
             .onDelete(perform: removeAccount)
         }
         .searchable(text: $searchText)
         .navigationTitle("Accounts")
         .navigationBarItems(trailing:
                                 Button(action: fetchAccounts) {
                                     Image(systemName: "arrow.clockwise")
                                 }
         )
     }.onAppear(perform: fetchAccounts)
 }
 
 func fetchAccounts() {
     if let apiServer = authenticationManager.apiServer,
        let accessToken = authenticationManager.accessToken {
         accountManager.fetchAccounts(apiServer: apiServer, accessToken: accessToken)
     }
 }
 
 func removeAccount(at offsets: IndexSet) {
     accountManager.accountList.remove(atOffsets: offsets)
 }
}*/





