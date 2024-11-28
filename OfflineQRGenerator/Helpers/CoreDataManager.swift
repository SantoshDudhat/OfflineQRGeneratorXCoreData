//
//  CoreDataManager.swift
//  OfflineQRGenerator
//
//  Created by DREAMWORLD on 28/11/24.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "OfflineQRGenerator")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    func saveEvent(id: Int64, name: String, image: String, location: String, latitude: Double, longitude: Double, qrCodeUrl: String) {
        let context = persistentContainer.viewContext
        let event = EventDetails(context: context)
        
        event.id = id
        event.name = name
        event.image = image
        event.location = location
        event.latitude = latitude
        event.longitude = longitude
        event.qrCodeUrl = qrCodeUrl
        
        do {
            try context.save()
            print("Event saved successfully!")
        } catch {
            print("Failed to save event: \(error)")
        }
    }
    
    func fetchAllEvents() -> [EventDetails] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<EventDetails> = EventDetails.fetchRequest()
        
        do {
            let events = try context.fetch(fetchRequest)
            return events
        } catch {
            print("Failed to fetch events: \(error)")
            return []
        }
    }
    
    func deleteAllData(entityName: String) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false

        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                if let objectData = object as? NSManagedObject {
                    context.delete(objectData)
                }
            }
            try context.save()
            print("All data in \(entityName) deleted successfully.")
        } catch {
            print("Failed to delete all data in \(entityName): \(error)")
        }
    }

    func deleteEvent(event: EventDetails) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(event)
        
        do {
            try context.save()
            print("Event deleted successfully!")
        } catch {
            print("Failed to delete event: \(error)")
        }
    }
}
