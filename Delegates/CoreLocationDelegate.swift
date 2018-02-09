//
//  MyLocationDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/30/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit
import CoreLocation

@objc protocol CoreLocationDelegate: class {    
    @objc optional func errorUpdatingLocations(_ error: Error)
    
    @objc optional func didUpdateLocations(manager: CLLocationManager, location: CLLocation)
    
    @objc optional func didStartLocationUpdates()
    
    @objc optional func didStopLocationUpdates()
}
