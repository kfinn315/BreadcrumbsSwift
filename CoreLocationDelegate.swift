//
//  MyLocationDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/30/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit

protocol CoreLocationDelegate: class
{
    func errorUpdatingLocations(_ Error: Error);
    
    func didUpdateLocations(manager: CLLocationManager, locations: [CLLocation]);
    
    func didStartLocationUpdates();
    
    func didStopLocationUpdates();
}
