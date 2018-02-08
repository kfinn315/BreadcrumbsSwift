//
//  Path+CoreDataClass.swift
//  
//
//  Created by Kevin Finn on 1/17/18.
//
//

import Foundation
import CoreData
import RxDataSources
import RxCoreData

@objc(Path)
public class Path: NSManagedObject, Persistable, IdentifiableType {
    var entitydescription : NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: "Path", in: NavTableViewController.managedObjectContext)!
    }
    public static var entityName: String = "Path"
    
    let decoder = JSONDecoder()
    public func getPoints() -> [Point] {
        do{
            if let json = (pointsJSON ?? "").data(using: .utf8) {
                return try decoder.decode([Point].self, from: json)
            }
        } catch {
            print("error "+error.localizedDescription)
        }
        return []

    }
    @objc public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(){
        super.init(entity: entitydescription, insertInto: nil)
    }

    public required init(entity: T) {
        super.init(entity: entitydescription, insertInto: nil)

        id = (entity.value(forKey: "id") as? String) ?? NSDate().string
        title = entity.value(forKey: "title") as? String
        notes = entity.value(forKey: "notes") as? String
        startdate = entity.value(forKey: "startdate") as? Date
        enddate = entity.value(forKey: "enddate") as? Date
        duration = entity.value(forKey: "duration") as! Float
        distance = entity.value(forKey: "distance") as! Double
        stepcount = (entity.value(forKey: "stepcount") as! Int64)
        pointsJSON = entity.value(forKey: "pointsJSON") as? String
        albumId = entity.value(forKey: "albumId") as? String
        coverimg = entity.value(forKey: "coverimg") as? Data
    }
    
    public typealias T = NSManagedObject
    
    public static var primaryAttributeName: String {
        return "id"
    }
    
    public func update(_ entity: T) {
        entity.setValue(id, forKey: "id")
        entity.setValue(notes, forKey: "notes")
        entity.setValue(title, forKey: "title")
        entity.setValue(albumId, forKey: "albumId")
        entity.setValue(locations, forKey: "locations")
        
        do {
            try entity.managedObjectContext?.save()
        } catch let e {
            print(e)
        }
    }
    
    public typealias Identity = String
    
    public var identity: Identity {
        return id ?? ""
    }
}

