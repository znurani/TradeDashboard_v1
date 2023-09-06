//
//  SettingsView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var selection: Int? = nil
    
    var body: some View {
        
        NavigationStack {
            
            List {
                
                NavigationLink(destination: AccountsView(), tag: 1, selection: $selection)
                {
                    
                    Image(systemName: "person.crop.circle")
                    Text("Accounts")
                }
                
                NavigationLink(destination: AuthenticationView(), tag: 2, selection: $selection)
                {
                    Image(systemName: "key")
                    Text("Authentication")
                  
                }
                .navigationBarTitle("Settings")
            }
        }
    }
}



#Preview {
    SettingsView()
}
