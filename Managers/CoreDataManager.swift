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
    var context : NSManagedObjectContext!
    
    init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.context = appDelegate.managedObjectContext
        }
    }
}
class PointsManager : CoreDataManager {
    func savePoint(_ localpoint: LocalPoint) {
        log.debug("savePoint")
        
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
                do {
                    try localcontext!.save()
                } catch {
                    log.error("error \(error)")
                }
            }
        }
    }
    
    func clearPoints() {
        log.debug("clearPoints")
        
        guard context != nil else {
            return
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
            let request = NSBatchDeleteRequest(fetchRequest: fetch)
            
            do {
                try localcontext!.execute(request)
            } catch {
                log.error("error \(error)")
            }
            
        }
    }
    
    func fetchPoints() -> [Point] {
        var points = [Point]()
        
        log.debug("fetchPoints -> fetching points")
        
        guard context != nil else {
            return []
        }
        
        context!.perform {
            [weak localcontext = self.context] in
            guard localcontext != nil else { return }
            
            let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
            
            do {
                points = try localcontext!.fetch(fetchRequest)
            } catch {
                log.error("error \(error)")
            }
            
            log.debug("fetched "+String(describing: points.count)+" points")
            
        }
        
        return points
    }
}
class PathsManager : CoreDataManager {
//    private func getPointsData() -> (array: [Point], json: String?, distance: Double){
//
//        var points : [Point] = []
//        let fetchRequest : NSFetchRequest<Point> = Point.fetchRequest()
//        var pointsJSON : String?
//
//        do {
//            points = try self.context.fetch(fetchRequest)
//        } catch {
//            log.error("error \(error)")
//        }
//
//        log.verbose("saving "+String(describing: points.count)+" points to new path")
//        do {
//            pointsJSON = String(data: try JSONEncoder().encode(points), encoding: .utf8)
//        } catch {
//            log.error("error "+error.localizedDescription)
//        }
//
//        var pointDistance : (endPoint: CLLocation?, distance: CLLocationDistance) = (nil, 0.0)
//        pointDistance = points.reduce(into: pointDistance, { (pointDistance, point) in
//            if(pointDistance.endPoint == nil){ //first
//                pointDistance.endPoint = CLLocation(point.coordinates)
//            } else{
//                pointDistance.distance += pointDistance.endPoint!.distance(from: CLLocation(point.coordinates))
//                log.verbose("distance \(pointDistance.distance)")
//            }
//        })
//
//       // path.distance = pointDistance.distTo
//
//        return (points, pointsJSON, pointDistance.distance)
//    }
//
//    func save(path: Path, callback: @escaping (Path?,Error?) -> Void) {
//        guard context != nil else {
//            log.debug("context == nil")
//            return
//        }
//
//        let pointsData = getPointsData()
//
//        path.pointsJSON = pointsData.json
//        path.distance = pointsData.distance as NSNumber
//
//        //time duration
//        if path.startdate == nil, path.enddate != nil {
//            path.startdate = path.enddate
//        } else if path.enddate == nil, path.startdate != nil {
//            path.enddate = path.startdate
//        } else if path.startdate == nil, path.enddate == nil {
//            path.startdate = Date()
//            path.enddate = path.startdate //now
//        }
//        path.duration = DateInterval(start: path.startdate!, end: path.enddate!).duration as NSNumber
//
//        //get location names
//        let points = pointsData.array
//        if let point1 = points.first {
//            CLGeocoder().reverseGeocodeLocation(CLLocation(point1.coordinates), completionHandler: { [weak self] (placemarks, error) in
//
//                guard let locality = placemarks?[0].locality else {
//                    log.debug("reverse geocode lookup returned no locality")
//                    return
//                }
//
//                do{
//                    log.debug("reverse geocode returned \(locality)")
//                    path.locations = locality
//                    try self?.context?.rx.update(path)
//                } catch{
//                    //update failed
//                    log.error(error.localizedDescription)
//                }
//            })
//        }
//
//        do{
//            try context?.rx.update(path)
//            callback(path, nil)
//        } catch {
//            log.error(error.localizedDescription)
//            callback(nil, error)
//        }
//    }

//    func getPath(_ pathid: String) -> Path? {
//        log.info("GET PATH \(pathid)")
//
//        var path : Path?
//
//        guard context != nil else {
//            log.debug("context is nil")
//            return nil
//        }
//
//        do {
//            let fetchRequest : NSFetchRequest<Path> = Path.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "id = %@", pathid)
//            fetchRequest.fetchLimit = 1
//
//            path = try context!.fetch(fetchRequest).first
//        } catch {
//            log.error("error \(error)")
//        }
//
//        return path
//    }
//
//    func getPaths() throws -> [Path] {
//        var paths : [Path] = []
//
//        guard context != nil else {
//            log.debug("context is nil")
//            return []
//        }
//
//        let fetchRequest : NSFetchRequest<Path> = Path.fetchRequest()
//        paths = try context!.fetch(fetchRequest)
//
//        return paths
//    }
//    func updatePath(pathid: String, properties: [AnyHashable : Any], callback: @escaping ([NSManagedObjectID],Error?) -> Void) {
//        guard context != nil else {
//            callback([],nil)
//            return
//        }
//
//        context!.perform {
//            [weak localcontext = self.context] in
//            guard localcontext != nil else { return }
//
//            do {
//                let request = NSBatchUpdateRequest(entityName: "Path")
//                request.propertiesToUpdate = properties
//                request.predicate = NSPredicate(format: "id = %@", pathid)
//                request.resultType = NSBatchUpdateRequestResultType.updatedObjectIDsResultType
//
//                let resObject = try localcontext!.execute(request)
//
//                if let result = resObject as? NSBatchUpdateResult, let updatedIds = result.result  as? [NSManagedObjectID] {
//
//                    if updatedIds.count > 0 {
//                        for objectID in updatedIds {
//                            let managedObject = localcontext!.object(with: objectID)
//                            localcontext!.refresh(managedObject, mergeChanges: false)
//                        }
//                    }
//
//                    callback(updatedIds,nil)
//                }
//            } catch {
//                print("error \(error)")
//                callback([],error)
//            }
//        }
//    }
//
//    func updatePath(_ path: Path, callback: @escaping ([NSManagedObjectID],Error?) -> Void ) {
//        var props : [AnyHashable : Any] = ["title":path.title ?? "", "notes":path.notes ?? "", "locations":path.locations ?? ""]
//
//        if let startdate = path.startdate {
//            props["startdate"] = startdate
//        }
//
//        if let enddate = path.enddate {
//            props["enddate"] = enddate
//        }
//
//        updatePath(pathid: path.id!, properties: props, callback: callback)
//    }
}
