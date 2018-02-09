//
//  LocationSettings.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/7/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation

public struct LocationSettings {
    static var locationAccuracy = kCLLocationAccuracyNearestTenMeters
    static var significantUpdatesOn = false
    static var backgroundLocationUpdatesOn = true
    static var minimumDistance = CLLocationDistance(Double(4))

}
