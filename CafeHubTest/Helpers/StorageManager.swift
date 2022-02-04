//
//  StorageManager.swift
//  CafeHubTest
//
//  Created by Vladislav Mazurov on 11.01.22.
//

import CoreData
import UIKit

class StorageManager {
    
    static let sharedManager = StorageManager()
    private init() {}
    
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
    
    func addPlace(name: String, address: String, zip: String, imageLink: String, rating: Double, type: [String], placeDescription: String, openingHours: String, wantToGo: Bool) {
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedPlaces")
        fetchRequest.predicate = NSPredicate(format: "name == %@" ,name)
        
        do {
            let item = try managedContext.fetch(fetchRequest)
            if item.count > 0 {
                return
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "SavedPlaces", in: managedContext)!
        let place = NSManagedObject(entity: entity, insertInto: managedContext)
        
        place.setValue(name, forKeyPath: "name")
        place.setValue(address, forKeyPath: "address")
        place.setValue(zip, forKey: "zip")
        place.setValue(imageLink, forKey: "imageLink")
        place.setValue(rating, forKey: "rating")
        place.setValue(type, forKey: "type")
        place.setValue(placeDescription, forKey: "placeDescription")
        place.setValue(openingHours, forKey: "openingHours")
        place.setValue(wantToGo, forKey: "wantToGo")
        
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func update(wantToGo: Bool, place: SavedPlaces) {
        let context = StorageManager.sharedManager.persistentContainer.viewContext
        
        place.setValue(wantToGo, forKeyPath: "wantToGo")
        
        do {
            try context.save()
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
    
    func fetchAllSavedPlaces() -> [SavedPlaces]?{
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedPlaces")
        
        do {
            let places = try managedContext.fetch(fetchRequest)
            return places as? [SavedPlaces]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func fetchAllSavedPlacesAsCafe() -> [Cafe]? {
        var placesCafe: [Cafe] = [Cafe]()
        if let places = self.fetchAllSavedPlaces() {
            for place in places {
                placesCafe.append(Cafe(name: place.name!, address: place.address!, zip: place.zip!,
                                       imageLink: place.imageLink!, type: place.type!, rating: place.rating, placeDescription: place.placeDescription!, openingHours: place.openingHours!))
            }
            return placesCafe
        } else {
            return nil
        }
    }
    
    func delete(name: String) {
        
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedPlaces")
        
        fetchRequest.predicate = NSPredicate(format: "name == %@" ,name)
        do {
            let item = try managedContext.fetch(fetchRequest)
            //var arrRemovedPlace = [SavedPlaces]()
            for i in item {
                managedContext.delete(i)
                try managedContext.save()
                //arrRemovedPlace.append(i as! SavedPlaces)
            }
            //return arrRemovedPlace
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            //return nil
        }
    }
    
    func find(name: String) -> SavedPlaces? {
        let managedContext = StorageManager.sharedManager.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedPlaces")
        
        fetchRequest.predicate = NSPredicate(format: "name == %@" ,name)
        do {
            let item = try managedContext.fetch(fetchRequest)
            var foundPlaces = [SavedPlaces]()
            for i in item {
                foundPlaces.append(i as! SavedPlaces)
            }
            return foundPlaces.first
            
            /*if !item.isEmpty {
                return true
            } else {
                return false
            }*/
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
}
