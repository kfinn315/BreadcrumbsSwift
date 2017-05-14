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
    
    @available(iOS 10.0, *)
    func savePoint(latitude: Double, longitude: Double, timestamp: Date) {
        print("savePoint")
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Point",
                                       in: managedContext)!
        
        let point = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        // 3
        point.setValue(latitude, forKeyPath: "latitude")
        point.setValue(longitude, forKeyPath: "longitude")
        point.setValue(timestamp, forKeyPath: "date")
        // 4
        do {
            try managedContext.save()
            points.append(point)
            print("append saved point ("+String(latitude)+","+String(longitude)+","+String(describing: timestamp)+")to points")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @available(iOS 10.0, *)
    func clearPoints(){
        print("clearPoints");
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        for point in points {
            managedContext.delete(point)
        }
        
        do {
            try managedContext.save();
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    @available(iOS 10.0, *)
    func fetchPoints() -> [NSManagedObject]?{
        print("fetchPoints -> fetching points");
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        //let managedContext = Storage.shared.context;
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Point")
        
        do {
            points = try managedContext.fetch(fetchRequest)
            print("fetched "+String(describing: points.count)+" points")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return points;
    }
}
