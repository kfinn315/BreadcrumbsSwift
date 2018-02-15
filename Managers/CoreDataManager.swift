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
    weak var context : NSManagedObjectContext?
    
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
