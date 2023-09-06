//
//  AppTabView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct AppTabView: View {
    
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        
        
        TabView{
            
            ContentView()
                .tabItem{
                    Label("Dashboard", systemImage: "house")
                }
            
         
            SettingsView()
                .badge("!")
                .tabItem {
                    Label("Settings", systemImage:"gear")
                }
            
        }
    }
}

#Preview {
    AppTabView()
        .environmentObject(AccountManager())
        .environmentObject(AuthenticationManager())
       
}
