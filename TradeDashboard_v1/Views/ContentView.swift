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
        NavigationStack{
         
            VStack{
                
            Text("Open PNL")
                Text("")
                
            }.navigationTitle("Dashboard")
            
        }
    }
}

#Preview {
    ContentView()
}
