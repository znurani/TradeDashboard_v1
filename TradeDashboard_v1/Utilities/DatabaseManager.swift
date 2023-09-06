//
//  DatabaseManager.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-09-05.
//

import SQLite3

/*
 
 import SQLite

 class DatabaseManager {
     static let shared = DatabaseManager()
     private var db: Connection?

     private let authTable = Table("authentication")
     private let refreshToken = Expression<String>("refreshToken")
     private let accessToken = Expression<String?>("accessToken")
     private let apiServer = Expression<String?>("apiServer")
     private let expiresIn = Expression<Int?>("expiresIn")
     private let tokenType = Expression<String?>("tokenType")
     private let tokenValid = Expression<Bool>("tokenValid")
     private let errorOccured = Expression<Bool>("errorOccured")
     private let errorMessage = Expression<String>("errorMessage")

     private init() {
         do {
             let path = NSSearchPathForDirectoriesInDomains(
                 .documentDirectory, .userDomainMask, true
             ).first!
             
             db = try Connection("\(path)/db.sqlite3")
             try setupDatabase()
         } catch {
             print("Database connection failed: \(error)")
         }
     }

     private func setupDatabase() throws {
         try db?.run(authTable.create(ifNotExists: true) { t in
             t.column(refreshToken)
             t.column(accessToken)
             t.column(apiServer)
             t.column(expiresIn)
             t.column(tokenType)
             t.column(tokenValid)
             t.column(errorOccured)
             t.column(errorMessage)
         })
     }
     
     func saveAuthentication(auth: AuthenticationManager) {
         let insert = authTable.insert(
             refreshToken <- auth.refreshToken,
             accessToken <- auth.accessToken,
             apiServer <- auth.apiServer,
             expiresIn <- auth.expiresIn,
             tokenType <- auth.tokenType,
             tokenValid <- auth.tokenValid,
             errorOccured <- auth.errorOccured,
             errorMessage <- auth.errorMessage
         )
         do {
             try db?.run(insert)
         } catch {
             print("Insert failed: \(error)")
         }
     }

     func loadAuthentication() -> AuthenticationManager? {
         do {
             for auth in try db!.prepare(authTable) {
                 return AuthenticationManager(
                     refreshToken: auth[refreshToken],
                     accessToken: auth[accessToken],
                     apiServer: auth[apiServer],
                     expiresIn: auth[expiresIn],
                     tokenType: auth[tokenType],
                     tokenValid: auth[tokenValid],
                     errorOccured: auth[errorOccured],
                     errorMessage: auth[errorMessage]
                 )
             }
         } catch {
             print("Select failed: \(error)")
         }
         return nil
     }
 }

 */
