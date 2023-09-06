//
//  AuthView.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-08-22.
//

import SwiftUI

struct AuthenticationView: View {
    
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @EnvironmentObject var accountManager: AccountManager
    
    var body: some View {
        
        VStack {
            Text("Questrade Login")
                .font(.largeTitle)
                .padding(.bottom, 50)
            
            VStack(alignment: .leading) {
                Text("Please enter your refresh token below:")
                    .font(.subheadline)
                HStack{
                    TextField("Enter refresh token", text: $authenticationManager.refreshToken)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: pasteRefreshToken) {
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.blue)
                    }
                }
            }.padding(.bottom, 20)
            
            Button(action: {
                authenticationManager.postRequest()
            }) {
                Text(authenticationManager.tokenValid ? "Account Authenticated" : "Get Access Token")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(authenticationManager.tokenValid ? Color.green : Color.blue)
                    .cornerRadius(10)
            }.padding(.top, 20)
            
            if authenticationManager.tokenValid {
                Text("Refresh Token Status: VALID")
                    .font(.headline)
                    .foregroundColor(Color.green)
                    .padding(.top, 20)
                
                // Logout Button
                Button(action: {
                    authenticationManager.logout() // Calls the logout method in your AuthenticationModel
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading) {
                    Text("Access Token:")
                        .font(.headline)
                        .bold()
                    Text(authenticationManager.accessToken ?? "N/A")
                        .font(.subheadline)
                    
                    Text("Refresh Token:")
                        .font(.headline)
                        .bold()
                    Text(authenticationManager.refreshToken)
                        .font(.subheadline)
                    
                    Text("Expires In:")
                        .font(.headline)
                        .bold()
                    Text(authenticationManager.expiresIn.map { String($0) } ?? "N/A seconds")
                        .font(.subheadline)
                }.padding()
            }

            
        }
        .padding()
        .alert(isPresented: $authenticationManager.errorOccured) {
            Alert(title: Text("Error"), message: Text(authenticationManager.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func pasteRefreshToken() {
            if let pastedString = UIPasteboard.general.string {
                authenticationManager.refreshToken = pastedString
            }
        }
}


#Preview {
    AuthenticationView()
        .environmentObject(AccountManager())
        .environmentObject(AuthenticationManager())
}
