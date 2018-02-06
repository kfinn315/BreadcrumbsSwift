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
    var context : NSManagedObjectContext?
    
    init(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.context = appDelegate.managedObjectContext
        }
    }
}
class PointsManager : CoreDataManager {
    func savePoint(_ localpoint: LocalPoint) {
        print("savePoint")
        
        guard context != nil else {
            return
        }
        
        context!.perform { [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            let point = Point(context: localcontext!)
            point.latitude = localpoint.latitude
            point.longitude = localpoint.longitude
            point.timestamp = localpoint.timestamp as Date?
            point.id = localpoint.timestamp?.string
            
            if localcontext!.hasChanges {
                do{
                    try localcontext!.save()
                } catch{
                    print("error \(error)")
                }
            }
        }
    }
    
    func clearPoints() {
        print("clearPoints");
        
        guard context != nil else {
            return
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do{
                try localcontext!.execute(request)
            } catch{
                print("error \(error)")
            }
            
        }
    }
    
    func fetchPoints() -> Array<Point> {
        var points = Array<Point>();
        
        print("fetchPoints -> fetching points");
        
        guard context != nil else {
            return []
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
            
            do{
                points = try localcontext!.fetch(fetchRequest)
            } catch{
                print("error \(error)")
            }
            
            print("fetched "+String(describing: points.count)+" points")
           
        }
        
        return points
    }
}
class PathsManager : CoreDataManager {
    //save all points to a path
    func savePath(start: Date, end: Date, title: String, notes: String?, steps: Int64?, distance: Double?, callback: @escaping (Error?)->()) {
        
        guard context != nil else {
            return
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            var points : [Point] = []
            let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
            
            do{
                points = try localcontext!.fetch(fetchRequest)
            } catch{
                print("error \(error)")
            }
            
            print("fetched "+String(describing: points.count)+" points")
            
            
            let path = Path(context: localcontext!)
            
            do{
                path.pointsJSON = String(data: try JSONEncoder().encode(points), encoding: .utf8)
            }
            catch{
                print("error "+error.localizedDescription)
            }
            
            path.startdate = start
            path.enddate = end
            path.title = title
            path.notes = notes ?? ""
            path.distance = distance ?? 0
            path.stepcount = steps ?? 0
            path.id = path.startdate?.string
            
            do{
                if self.context!.hasChanges{
                    try localcontext!.save()
                    localcontext!.refreshAllObjects()
                    callback(nil)
                }
            } catch{
                print("error \(error)")
                callback(error)
            }
        }
    }
    
    func getPath(_ id: String) -> Path? {
        var path : Path?
        
        guard context != nil else {
            return nil
        }
        
        do{
            let fetchRequest : NSFetchRequest<Path> = Path.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            fetchRequest.fetchLimit = 1
            
            path = try context!.fetch(fetchRequest).first
        } catch{
            print("error \(error)")
        }
        
        return path
    }
    
    func getPaths() throws -> [Path] {
        var paths : [Path] = []
        
        guard context != nil else{
            return []
        }
        
        do{
            let fetchRequest : NSFetchRequest<Path> = Path.fetchRequest()
            paths = try context!.fetch(fetchRequest)
        } catch{
            print("error \(error)")
        }
        
        return paths
    }
    
    func updatePath(id: String, properties: [AnyHashable : Any], callback: @escaping (Int)->()) {
        guard context != nil else{
            callback(-1)
            return
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            do{
                let request = NSBatchUpdateRequest(entityName: "Path")
                request.propertiesToUpdate = properties
                request.predicate = NSPredicate(format: "id = %@", id)
                request.resultType = NSBatchUpdateRequestResultType.updatedObjectIDsResultType
                
                let resObject = try localcontext!.execute(request)
                
                if let result = resObject as? NSBatchUpdateResult, let updatedIds = result.result  as? [NSManagedObjectID] {
                    
                    if updatedIds.count > 0 {
                        for objectID in updatedIds {
                            let managedObject = localcontext!.object(with: objectID)
                            localcontext!.refresh(managedObject, mergeChanges: false)
                        }
                    }
                    
                    callback(updatedIds.count)
                }
            } catch{
                print("error \(error)")
                callback(-1)
            }
        }
    }
    
    func updatePath(_ path: Path, callback: @escaping (Int)->()) {
        var props : [AnyHashable : Any] = ["title":path.title ?? "", "notes":path.notes ?? "", "locations":path.locations ?? ""]
        
        if let startdate = path.startdate {
            props["startdate"] = startdate
        }
        
        if let enddate = path.enddate {
            props["enddate"] = enddate
        }
        
        updatePath(id: path.id!, properties: props, callback: callback)
    }
}
