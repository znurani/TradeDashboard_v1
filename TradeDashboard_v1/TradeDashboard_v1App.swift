//
//  TradeDashboard_v1App.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

@main
struct TradeDashboard_v1App: App {
    
    @StateObject var accountManager = AccountManager()
    @StateObject var authenticationManager = AuthenticationManager()
    
    var body: some Scene {
        WindowGroup {
            
            AppTabView()
                .environmentObject(AuthenticationManager())
                .environmentObject(AccountManager())
            
        
        }
        
     
    }
}
