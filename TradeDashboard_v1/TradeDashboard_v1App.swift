//
//  TradeDashboard_v1App.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

@main
struct TradeDashboard_v1App: App {
    
    @StateObject var authenticationManager = AuthenticationManager()
    @StateObject var accountManager = AccountManager()

    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authenticationManager) 
                .environmentObject(accountManager)
        }
    }
}


