//
//  LocalPoint.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/25/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation

class LocalPoint {
        public var latitude: Double
        public var longitude: Double
        public var timestamp: NSDate?
    
    required init(lat: Double, lng: Double, time: NSDate? = nil) {
        latitude = lat
        longitude = lng
        timestamp = time
    }
    
    public static func from(_ loc: CLLocation) -> LocalPoint {
        return LocalPoint(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude, time: loc.timestamp as NSDate)
    }
    
}
