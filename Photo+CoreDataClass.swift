//
//  Photo+CoreDataClass.swift
//  
//
//  Created by Kevin Finn on 1/18/18.
//
//

import UIKit
import Foundation
import CoreData
import RxCoreData
import RxSwift
import RxCocoa
import RxDataSources

@objc(Photo)
public class Photo: NSManagedObject, Persistable, IdentifiableType {
    @NSManaged public var id: String
    @NSManaged public var pathID: String
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var url: URL?
    
    var entitydescription : NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: "Photo", in: ((UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext)!)!
    }
    public static var entityName: String = "Photo"
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(){
        super.init(entity: entitydescription, insertInto: nil)
    }
    
    public required init(entity: T) {
        super.init(entity: entitydescription, insertInto: nil)
        
        if let entityID = entity.value(forKey: "id") as? String {
            id = entityID
        }
        
        if let entityPID = entity.value(forKey: "pathID") as? String {
            pathID = entityPID
        }
        
        timestamp = entity.value(forKey: "timestamp") as? NSDate
        
        if let entityLNG = entity.value(forKey: "longitude") as? Double
        {
            longitude = entityLNG
        }
        if let entityLAT = entity.value(forKey: "latitude") as? Double {
            latitude = entityLAT
        }
        
        url = entity.value(forKey: "url") as? URL
    }
    
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    public static var primaryAttributeName: String {
        return "id"
    }
    
    public var identity: String {
        return "id"
    }
    
    public func update(_ entity: NSManagedObject) {
        
    }
    
    public typealias T = NSManagedObject
    
    public typealias Identity = String
}
