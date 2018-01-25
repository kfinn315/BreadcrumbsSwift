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

class CoreDataManager {
    var container : NSPersistentContainer?
    //var managedObjectContext : NSManagedObjectContext?
    
    init(){
        //        DispatchQueue.main.async {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.container = appDelegate.persistentContainer
            //self.managedObjectContext = appDelegate.managedObjectContext
        }
        //        }
    }
}
class PointsManager : CoreDataManager {
    //var points : [NSManagedObject] = [];
    
    func savePoint(_ point: Point) {
        print("savePoint")
        
        guard container != nil else {
            return
        }
        
        container?.performBackgroundTask({ (context) in
            let entity = NSEntityDescription.entity(forEntityName: "Point", in: context)!
            
            let mopoint = NSManagedObject(entity: entity, insertInto: context)
            mopoint.setValue(point.id, forKey: "id")
            mopoint.setValue(point.latitude, forKeyPath: "latitude")
            mopoint.setValue(point.longitude, forKeyPath: "longitude")
            mopoint.setValue(point.timestamp, forKeyPath: "timestamp")
            
            if context.hasChanges {
                do{
                    try context.save()
                } catch{
                    print("error \(error)")
                }
            }
        })
    }
    
    func clearPoints() {
        print("clearPoints");
        
        guard container != nil else {
            return
        }
        
        container?.performBackgroundTask({ (context) in
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do{
                try context.execute(request)
            } catch{
                print("error \(error)")
            }
            
        })
        //        points.removeAll()
    }
    
    func fetchPoints() -> Array<Point> {
        var points = Array<Point>();
        
        print("fetchPoints -> fetching points");
        
        guard container != nil else {
            return []
        }
        
        container!.performBackgroundTask { (context) in
            var mojs : [NSManagedObject] = []
            
            let fetchRequest = NSFetchRequest<Point>(entityName: "Point")
            
            do{
                mojs = try context.fetch(fetchRequest)
            } catch{
                print("error \(error)")
            }
            
            print("fetched "+String(describing: points.count)+" points")
            
            for point in mojs {
                let lat = point.value(forKey: "latitude") as! Double
                let long = point.value(forKey: "longitude") as! Double
                let time = point.value(forKey: "timestamp") as! NSDate
                let id = point.value(forKey: "id") as? String ?? time.description
                points.append(Point(id: id, lat: lat, lng: long, time: time))
            }
        }
        
        return points
    }
}
class PathsManager : CoreDataManager {
    //save all points to a path
    func savePath(_ path: Path) {
        guard container != nil else {
            return
        }
        
        container!.performBackgroundTask { (context) in
            do{
                
                if let entity = NSEntityDescription.entity(forEntityName: "Path", in: context) {
                    let pEntity = NSManagedObject(entity: entity, insertInto: context)
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
                }
                
                if context.hasChanges{
                    try context.save()
                }
            } catch{
                print("error \(error)")
            }
        }
    }
    
    func getPath(_ id: String) -> Path? {
        var path : Path?
        
        guard container != nil else {
            return nil
        }
        
        container!.performBackgroundTask { (context) in
            do{
                let fetchRequest = NSFetchRequest<Path>(entityName: "Path")
                fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                fetchRequest.fetchLimit = 1
                
                path = try context.fetch(fetchRequest).first
            } catch{
                print("error \(error)")
            }
        }
        
        return path
    }
    
    func getPaths() throws -> [Path] {
        var paths : [Path] = []
        
        guard container != nil else{
            return []
        }
        
        container!.performBackgroundTask { (context) in
            do{
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Path")
                
                let mojs = try context.fetch(fetchRequest)
                
                for pathData in mojs {
                    let path = Path(entity: pathData)
                    paths.append(path)
                }
            } catch{
                print("error \(error)")
            }
        }
        
        return paths
    }
    
    func updatePath(id: String, properties: [AnyHashable : Any]) -> Int{
        var changeCount = 0
        
        guard container != nil else{
            return 0
        }
        
        container!.performBackgroundTask { (context) in
            do{
                let request = NSBatchUpdateRequest(entityName: "Path")
                request.propertiesToUpdate = properties
                request.predicate = NSPredicate(format: "id = %@", id)
                request.resultType = NSBatchUpdateRequestResultType.updatedObjectIDsResultType
                
                let resObject = try context.execute(request)
                
                if let result = resObject as? NSBatchUpdateResult, let updatedIds = result.result  as? [NSManagedObjectID] {
                    
                    if updatedIds.count > 0 {
                        for objectID in updatedIds {
                            let managedObject = context.object(with: objectID)
                            context.refresh(managedObject, mergeChanges: false)
                        }
                    }
                    
                    changeCount = updatedIds.count
                }
            } catch{
                print("error \(error)")
            }
        }
        
        return changeCount
    }
    
    func updatePath(_ path: Path) -> Int{
        var props : [AnyHashable : Any] = ["title":path.title ?? "", "notes":path.notes ?? "", "locations":path.locations ?? ""]
        
        if let startdate = path.startdate {
            props["startdate"] = startdate
        }
        
        if let enddate = path.enddate {
            props["enddate"] = enddate
        }
        
        return updatePath(id: path.id!, properties: props)
    }
}
