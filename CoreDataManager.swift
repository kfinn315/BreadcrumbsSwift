//
//  CoreDataManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/1/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager{
    var points : [NSManagedObject] = [];
    
    func savePoint(latitude: Double, longitude: Double, timestamp: Date) throws {
        print("savePoint")
        
        // 1
        let managedContext = GetManagedObjectContext()
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Point", in: managedContext!)!
        
        let point = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        // 3
        point.setValue(latitude, forKeyPath: "latitude")
        point.setValue(longitude, forKeyPath: "longitude")
        point.setValue(timestamp, forKeyPath: "date")
        // 4
        
        if(managedContext?.hasChanges)!{
            try managedContext?.save()
        }

        points.append(point)
        print("append saved point ("+String(latitude)+","+String(longitude)+","+String(describing: timestamp)+")to points")
    }
    
    func clearPoints() throws{
        print("clearPoints");
        
        let managedContext = GetManagedObjectContext();
        
        for point in points {
            managedContext?.delete(point)
        }
        
        if(managedContext?.hasChanges)!{
            try managedContext?.save();
        }
        
    }
    
    func fetchPoints() throws -> [NSManagedObject]?{
        print("fetchPoints -> fetching points");
        
        let managedContext = GetManagedObjectContext()
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Point")
        
        points = try (managedContext)!.fetch(fetchRequest)
        
        print("fetched "+String(describing: points.count)+" points")
        
        return points;
    }
    
    
    private func GetManagedObjectContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        var managedContext : NSManagedObjectContext?
        
        if #available(iOS 10.0, *) {
            managedContext = appDelegate.persistentContainer.viewContext
        } else {
            // iOS 9.0 and below
            guard let modelURL = Bundle.main.url(forResource: "Model", withExtension:"momd") else {
                fatalError("Error loading model from bundle")
            }
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex-1]
            let storeURL = docURL.appendingPathComponent("Model.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
            
        }
        return managedContext;
    }
}
