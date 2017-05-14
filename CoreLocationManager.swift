                                //
//  MyLocationManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/30/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation
import CloudKit
import CoreData
import UIKit

class CoreLocationManager: NSObject, CLLocationManagerDelegate{
    static let sharedIntance = CoreLocationManager();
        var delegate : CoreLocationDelegate?;
        var currentPathID = 0;
        static var LManager : CLLocationManager!;
    var updating = false;
    
    internal override init() {
        super.init();
        
        if(CoreLocationManager.LManager == nil){
            CoreLocationManager.LManager = CLLocationManager();
        }
        
        if(LocationSettings.significantUpdatesOn && !CLLocationManager.significantLocationChangeMonitoringAvailable()){
            LocationSettings.significantUpdatesOn  = false;
        }
        
        CoreLocationManager.LManager.delegate = self;
        CoreLocationManager.updateSettings()
    }

    static func updateSettings(){
        LManager.desiredAccuracy = LocationSettings.locationAccuracy;
        LManager.distanceFilter = LocationSettings.minimumDistance;
        LManager.allowsBackgroundLocationUpdates = LocationSettings.backgroundLocationUpdatesOn;
        if(LocationSettings.significantUpdatesOn){
            LManager.startMonitoringSignificantLocationChanges()
        } else{
            LManager.stopMonitoringSignificantLocationChanges();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Manager did change auth status to "+String(describing: status))
        if(CLLocationManager.locationServicesEnabled()){
            CoreLocationManager.LManager = manager;
            CoreLocationManager.LManager.startUpdatingLocation()
        }
    }
    
    func startLocationUpdates(){
        print("start Location Updates()")
              
        let authStatus = CLLocationManager.authorizationStatus();
        print("CLLocationManager auth status = "+String(describing: authStatus))
        if(authStatus != CLAuthorizationStatus.authorizedAlways && authStatus != CLAuthorizationStatus.authorizedWhenInUse){
            CoreLocationManager.LManager.requestWhenInUseAuthorization();
            print("CL RequestWhenInUseAuthorization()")
        } else{
            //CoreLocationManager.LManager.requestLocation();
            if(CLLocationManager.locationServicesEnabled()){
                if(LocationSettings.significantUpdatesOn){
                    CoreLocationManager.LManager.startMonitoringSignificantLocationChanges();
                }
                else{
                    CoreLocationManager.LManager.startUpdatingLocation()
                }
                updating = true;
                delegate?.didStartLocationUpdates();
            }
            else{
                print("Location services enabled? FALSE")
            }
        }
    }
    
    func updatesAreOn() -> Bool{
        return updating;
    }

    
    func stopLocationUpdates(){
        if(LocationSettings.significantUpdatesOn){
            CoreLocationManager.LManager.stopMonitoringSignificantLocationChanges();
        }
        else{
            CoreLocationManager.LManager.stopUpdatingLocation()
        }
        print("Stop location updates")
        updating = false;
        delegate?.didStopLocationUpdates();
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        print("location manager didUpdateLocations");
        
        (delegate!).didUpdateLocations(manager: CoreLocationManager.LManager, locations: locations);
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager error \(error)");
    }
    
}
