//
//  StorageManager.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 11.01.22.
//

import CoreData
import UIKit

class StorageManager: NSPersistentContainer {
    
    static let sharedManager = StorageManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Places")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addPlace(name: String, address: String, zip: String, imageLink: String, rating: Double, type: [String]) {
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SavedPlaces", in: managedContext)!
        let place = NSManagedObject(entity: entity, insertInto: managedContext)
        
        place.setValue(name, forKeyPath: "name")
        place.setValue(address, forKeyPath: "address")
        place.setValue(zip, forKey: "zip")
        place.setValue(imageLink, forKey: "imageLink")
        place.setValue(rating, forKey: "rating")
        place.setValue(type, forKey: "type")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func update(name: String, address: String, zip: String, imageLink: String, rating: Double, type: [String], place: SavedPlaces) {
        let context = StorageManager.sharedManager.persistentContainer.viewContext
        
        place.setValue(name, forKeyPath: "name")
        place.setValue(address, forKeyPath: "address")
        place.setValue(zip, forKey: "zip")
        place.setValue(imageLink, forKey: "imageLink")
        place.setValue(rating, forKey: "rating")
        place.setValue(type, forKey: "type")
        
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } //catch {
    }
    
    func delete(place: SavedPlaces){
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        
        managedContext.delete(place)
        
        do {
            try managedContext.save()
        } catch {
            // Do something in response to error condition
        }
    }
    
    func fetchAllSavedPlaces() -> [Cafe]?{
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedPlaces")
        
        do {
            let places = try managedContext.fetch(fetchRequest)
            return places as? [Cafe]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    /*func delete(id: String) -> [Cafe]? {
        
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedPlaces")
        
        fetchRequest.predicate = NSPredicate(format: "id == %@" ,id)
        do {
            
            let item = try managedContext.fetch(fetchRequest)
            var arrRemovedPlace = [Cafe]()
            for i in item {
                managedContext.delete(i)
                try managedContext.save()
                arrRemovedPlace.append(i as! Cafe)
            }
            return arrRemovedPlace
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }*/
    
}
