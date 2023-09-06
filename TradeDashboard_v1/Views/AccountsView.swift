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
                                        accountManager.fetchAccounts(
                                            apiServer: authenticationManager.apiServer ?? "",
                                            accessToken: authenticationManager.accessToken ?? "",
                                            completion: {})
                                    })
                                {
                Image(systemName: "arrow.clockwise")
            }
            )
        }.onAppear(perform: {
            accountManager.fetchAccounts(
                apiServer: authenticationManager.apiServer ?? "",
                accessToken: authenticationManager.accessToken ?? "",
                completion: {})
        })
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





