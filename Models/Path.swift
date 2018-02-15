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
import CoreLocation

@objc(Path)
public class Path: NSManagedObject, Persistable, IdentifiableType {
    var entitydescription : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Path", in: AppDelegate.managedObjectContext!)!
    }
    public static var entityName: String = "Path"
    
    let decoder = JSONDecoder()
    public func getPoints() -> [CLLocationCoordinate2D] {
        do {
            if let json = (pointsJSON ?? "").data(using: .utf8) {
                let points = try decoder.decode([Point].self, from: json)
                 return points.map({(point: Point) -> CLLocationCoordinate2D in return point.coordinates})
            }
        } catch {
            log.error(error.localizedDescription)
        }
        return []

    }
    @objc public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init() {
        super.init(entity: entitydescription, insertInto: nil)
    }

    public required init(entity: T) {
        super.init(entity: entitydescription, insertInto: nil)

        localid = entity.value(forKey: "localid") as? String
        title = entity.value(forKey: "title") as? String
        notes = entity.value(forKey: "notes") as? String
        startdate = entity.value(forKey: "startdate") as? Date
        enddate = entity.value(forKey: "enddate") as? Date
        duration = entity.value(forKey: "duration") as? NSNumber
        distance = entity.value(forKey: "distance") as? NSNumber
        stepcount = entity.value(forKey: "stepcount") as? NSNumber
        pointsJSON = entity.value(forKey: "pointsJSON") as? String
        albumId = entity.value(forKey: "albumId") as? String
        coverimg = entity.value(forKey: "coverimg") as? Data
        locations = entity.value(forKey: "locations") as? String
    }
    
    public typealias T = NSManagedObject
    
    public static var primaryAttributeName: String {
        return "localid"
    }
    
    public func update(_ entity: T) {
       // entity.setValue(id, forKey: "id")
        entity.setValue(notes, forKey: "notes")
        entity.setValue(title, forKey: "title")
        entity.setValue(albumId, forKey: "albumId")
        entity.setValue(locations, forKey: "locations")
                
        do {
            try entity.managedObjectContext?.save()
        } catch {            
            log.error(error.localizedDescription)
        }
    }
    
    public typealias Identity = String
    
    public var identity: Identity {
        if self.localid == nil {
            self.localid = UUID().uuidString
        }
        return self.localid!
    }
    
    public var displayTitle : String {
        let title = self.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        return title?.isEmpty ?? false ? (locations ?? "-") : title!
    }
    
    //convert meters to miles
    public var displayDistance : String{
        guard distance != nil else {
            return "?"
        }
//
//        var measure = Measurement(value: self.distance!.doubleValue, unit: UnitLength.meters)
//
//        measure.convert(to: UnitLength.miles)
//
//        return (measure.value as NSNumber).formatted ?? "?"

        return self.distance?.formatted ?? "?"
    }
    
    public var displayDuration : String {
        guard duration != nil else {
            return "?"
        }
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        dateFormatter.unitsStyle = .abbreviated
      
        let timeinterval = TimeInterval(truncating: duration!)
        return dateFormatter.string(from: timeinterval) ?? "?"
    }
}

