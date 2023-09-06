//
//  CoreDataManager.swift
//  TradeDashboard_v1
//
//  Created by Zeshan Nurani on 2023-09-03.
//

import Foundation
import CoreData

/*class CoreDataManager {
 
 static let shared = CoreDataManager()
 
 lazy var persistentContainer: NSPersistentContainer = {
 let container = NSPersistentContainer(name: "TradeDashboard_v1")
 container.loadPersistentStores(completionHandler: { (storeDescription, error) in
 if let error = error as NSError? {
 print("Unresolved error \(error), \(error.userInfo)")
 }
 })
 return container
 }()
 
 private func saveContext () {
 let context = persistentContainer.viewContext
 if context.hasChanges {
 do {
 try context.save()
 } catch {
 let nserror = error as NSError
 print("Unresolved error \(nserror), \(nserror.userInfo)")
 }
 }
 }
 
 func saveAccountDetails(accountDetails: AccountManager.AccountDetails) {
 let context = persistentContainer.viewContext
 let accountEntity = NSEntityDescription.insertNewObject(forEntityName: "Account", into: context) as! Account
 
 // Set Core Data Account properties based on your AccountDetails struct
 accountEntity.setValue(accountDetails.id, forKey: "id")
 accountEntity.setValue(accountDetails.type, forKey: "type")
 // ... set other properties
 
 saveContext()
 }
 
 func savePositions(positions: [AccountManager.Position]) {
 let context = persistentContainer.viewContext
 
 for position in positions {
 let positionEntity = NSEntityDescription.insertNewObject(forEntityName: "Position", into: context) as! Position
 
 // Set Core Data Position properties based on your Position struct
 positionEntity.setValue(position.id, forKey: "id")
 positionEntity.setValue(position.symbol, forKey: "symbol")
 // ... set other properties
 
 saveContext()
 }
 }
 }
 */
