//
//  CoreDataManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/1/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import UIKit

class CoreDataManager{
    var points : [NSManagedObject] = [];
    var managedObjectContext : NSManagedObjectContext?
    
    init(){
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                self.managedObjectContext = appDelegate.managedObjectContext
            }
        }
    }
    
    //save all points to a path
    func savePath(_ path: Path) {
        //let points = try fetchPoints()
        
        //path.Points = points

        if managedObjectContext != nil, let entity = NSEntityDescription.entity(forEntityName: "Path", in: managedObjectContext!) {
            let pEntity = NSManagedObject(entity: entity, insertInto: managedObjectContext!)
            
            pEntity.setValue(path.id ?? path.startdate?.description ?? Date().description, forKeyPath: "id")
            pEntity.setValue(path.startdate, forKeyPath: "startdate")
            pEntity.setValue(path.enddate, forKeyPath: "enddate")
            pEntity.setValue(path.notes, forKey: "notes")
            pEntity.setValue(path.distance, forKey: "distance")
            pEntity.setValue(path.distance, forKey: "stepcount")
            pEntity.setValue(path.duration, forKey: "duration")
            pEntity.setValue(path.locations, forKey: "locations")
            pEntity.setValue(path.title, forKey: "title")
            pEntity.setValue(path.pointsJSON, forKey: "pointsJSON")

            if managedObjectContext!.hasChanges{                
                do{
                    try managedObjectContext!.save()
                } catch{
                    print("error "+error.localizedDescription)
                }
            }
        }
    }
    
    func getPaths() throws -> [Path] {
        let pathsCD = try getPathsCD()
        
        var paths : [Path] = []
        
        if pathsCD != nil {
            for pathData in pathsCD! {
                let path = Path(entity: pathData)
//                wrapper.path.pointsJSON = pathData.value(forKey: "pointsJSON") as? String
//                wrapper.path.date = pathData.value(forKey: "date") as? Date!
//                wrapper.path.title = pathData.value(forKey: "title") as? String
//                wrapper.path.notes = pathData.value(forKey: "notes") as? String
//                wrapper.path.distance  = pathData.value(forKey: "distance") as? Float
//                wrapper.path.duration = pathData.value(forKey: "duration") as? Float
//                wrapper.path.locations = pathData.value(forKey: "locations") as? String
//
                paths.append(path)
            }
            
        }
     
        return paths
    }
    private func getPathsCD() throws -> [NSManagedObject]?{
        guard managedObjectContext != nil else{
            return nil
        }

        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Path")
        
        let managedPaths = try managedObjectContext!.fetch(fetchRequest)
        
        return managedPaths
    }
    func savePoint(_ point: Point) throws {
        print("savePoint")

        guard managedObjectContext != nil else {
            return
        }

        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Point", in: managedObjectContext!)!
        
        let mopoint = NSManagedObject(entity: entity,
                                    insertInto: managedObjectContext!)
        
        // 3
        mopoint.setValue(point.id, forKey: "id")
        mopoint.setValue(point.latitude, forKeyPath: "latitude")
        mopoint.setValue(point.longitude, forKeyPath: "longitude")
        mopoint.setValue(point.timestamp, forKeyPath: "timestamp")
        // 4
        
        if(managedObjectContext?.hasChanges)!{
            try managedObjectContext?.save()
        }

        points.append(mopoint)
//        print("append saved point ("+String(latitude)+","+String(longitude)+","+String(describing: timestamp)+")to points")
    }
    
    func clearPoints() throws{
        print("clearPoints");
        
        guard managedObjectContext != nil else {
            return
        }

        for point in points {
            managedObjectContext!.delete(point)
        }
        
        if managedObjectContext!.hasChanges {
            try managedObjectContext!.save();
        }
    }
    
    func fetchPoints() throws -> Array<Point> {
        var data : [NSManagedObject]?
        
        data = try fetchPointsCD()
        
        var points = Array<Point>();

        if data != nil {
        // currentPath.removeAll()
        for point in data! {
            let lat = point.value(forKey: "latitude") as! Double
            let long = point.value(forKey: "longitude") as! Double
            let time = point.value(forKey: "timestamp") as! NSDate
            let id = point.value(forKey: "id") as? String ?? time.description
//            let clLat = CLLocationDegrees(lat)
//            let clLong = CLLocationDegrees(long)
//            
            points.append(Point(id: id, lat: lat, lng: long, time: time))
            
        }

        }
        
        return points
    }
    
    private func fetchPointsCD() throws -> [NSManagedObject]?{
        print("fetchPoints -> fetching points");
        
        guard managedObjectContext != nil else {
            return nil
        }

        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Point")
        
        points = try managedObjectContext!.fetch(fetchRequest)
        
        print("fetched "+String(describing: points.count)+" points")
        
        return points;
    }
    

    private func GetManagedObjectContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }

        var managedContext : NSManagedObjectContext?

        if #available(iOS 10.0, *) {
            managedContext = appDelegate.managedObjectContext
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
