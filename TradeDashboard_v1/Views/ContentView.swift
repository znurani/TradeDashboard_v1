//
//  SwiftUIView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var accountManager: AccountManager
    @EnvironmentObject var authenticationManager: AuthenticationManager
    
    var body: some View {
        
        TabView{
            
            AccountsView()
                .tabItem{
                    Label("Accounts", systemImage: "house")
                }
            
            AuthenticationView()
                .badge("!")
                .tabItem {
                    Label("Authentication", systemImage:"gear")
                }
        
        }
        
    }
}

#Preview {
    ContentView()
}
