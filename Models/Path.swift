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
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var notes: String?
    @NSManaged public var startdate: NSDate?
    @NSManaged public var enddate: NSDate?
    @NSManaged public var duration: Float
    @NSManaged public var stepcount : NSNumber?
    @NSManaged public var distance: Double
    @NSManaged public var locations: String?
    @NSManaged public var pointsJSON: String?
    @NSManaged public var albumId : String?
    
    var entitydescription : NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: "Path", in: ((UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext)!)!
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
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Path> {
        return NSFetchRequest<Path>(entityName: "Path")
    }
   
    private var _albumdata : PhotoCollection? 
    public var albumData : PhotoCollection? {
        get {
            return _albumdata
        }
        set {
            _albumdata = newValue
            albumId = newValue?.id
        }
    }

    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
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
        startdate = entity.value(forKey: "startdate") as? NSDate
        enddate = entity.value(forKey: "enddate") as? NSDate
        duration = entity.value(forKey: "duration") as! Float
        distance = entity.value(forKey: "distance") as! Double
        stepcount = (entity.value(forKey: "stepcount") as! NSNumber)
        pointsJSON = entity.value(forKey: "pointsJSON") as? String
        albumId = entity.value(forKey: "albumId") as? String
      
        if albumId != nil {
            _albumdata = PhotoManager.getPhotoCollection(from: albumId!)
        }
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

