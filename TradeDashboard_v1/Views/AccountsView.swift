//
//  MainView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct AccountsView: View {
    
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @EnvironmentObject var accountManager: AccountManager
    
    @State private var searchText: String = ""  // Define searchText
    
    var body: some View {
        NavigationView {
            List {
                ForEach(accountManager.accountList, id: \.id) { accountDetail in  // Loop through accountList
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
                                    Button(action: {
                                        fetchAccounts()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                    }
            ).onAppear {
               
                    fetchAccounts()
                
            }
        }
    }
    
    func removeAccount(at offsets: IndexSet) {
        accountManager.accountList.remove(atOffsets: offsets)
    }
    
    // Extracted the fetching logic to its own function for reusability
    func fetchAccounts() {
        accountManager.fetchAccounts(
            apiServer: authenticationManager.apiServer ?? "",
            accessToken: authenticationManager.accessToken ?? "",
            completion: {})
    }
}



#Preview {
    AccountsView()
        .environmentObject(AccountManager())
        .environmentObject(AuthenticationManager())

}





