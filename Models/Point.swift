//
//  Point+CoreDataClass.swift
//  
//
//  Created by Kevin Finn on 1/17/18.
//
//

import Foundation
import CoreData
import CoreLocation
import UIKit

@objc(Point)
public class Point: NSManagedObject, Codable {
    var entitydescription : NSEntityDescription{
        return NSEntityDescription.entity(forEntityName: "Point", in: ((UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext)!)!
    }
    
    @objc
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    public required init(){
        super.init(entity: entitydescription, insertInto: nil)
    }

    public convenience init(id: String? = nil, lat: Double, lng: Double, time: NSDate) {
        self.init()
        if id != nil {
            self.id = id!
        }
        latitude = lat
        longitude = lng
        timestamp = time as Date
    }
    
    public static func from(_ loc: CLLocation) -> Point{
        return Point(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude, time: loc.timestamp as NSDate)
    }
    
    public var coordinates : CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case latitude = "latitude"
        case longitude = "longitude"
        case id = "id"
        case timestamp = "timestamp"
    }
    
    public convenience required init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container
        self.latitude = try container.decode(Double.self, forKey: .latitude) // extracting the data
        self.id = try container.decode(String.self, forKey: .id) // extracting the data
        self.longitude = try container.decode(Double.self, forKey: .longitude) // extracting the data
        self.timestamp = try container.decode(Date.self, forKey: .timestamp) as Date
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        if timestamp != nil, let timeDate = timestamp as Date! {
            try container.encode(timeDate, forKey: .timestamp)
        }
    }


}
