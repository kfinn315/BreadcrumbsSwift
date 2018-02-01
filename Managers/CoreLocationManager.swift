//
//  MyLocationManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/30/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

//import UIKit
//import Foundation
import CoreLocation
//import CloudKit
//import CoreData
import RxSwift
import RxCocoa

class CoreLocationManager: NSObject, CLLocationManagerDelegate{
    static let sharedInstance = CoreLocationManager();
    weak var delegate : CoreLocationDelegate?;
    public var authorized : Driver<Bool>
    public var location : Driver<CLLocation>
    var updating = false;
    var disposeBag = DisposeBag()
    
    public let locationManager = CLLocationManager()
    
    internal override init() {
        locationManager.delegate = nil
        
        weak var weakLocationManager = locationManager
        
        authorized = Observable.deferred{
            let status = CLLocationManager.authorizationStatus()
            guard let strongLocationManager = weakLocationManager else {
                return Observable.just(status)
            }
            return strongLocationManager.rx.didChangeAuthorizationStatus.startWith(status)
        }.asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedWhenInUse: return true
                case .authorizedAlways: return true
                default: return false
            }
        }
        
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
          //  .filter { $0.count > 0 }
            .map { $0.last! }
        
        super.init()
        
        locationManager.requestAlwaysAuthorization()
        
        if(LocationSettings.significantUpdatesOn && !CLLocationManager.significantLocationChangeMonitoringAvailable()){
            LocationSettings.significantUpdatesOn  = false;
        }
        
        //locationManager.delegate = self;
        updateSettings()
    }

    func updateSettings(){
        locationManager.desiredAccuracy = LocationSettings.locationAccuracy;
        locationManager.distanceFilter = LocationSettings.minimumDistance;
        locationManager.allowsBackgroundLocationUpdates = LocationSettings.backgroundLocationUpdatesOn;
        if(LocationSettings.significantUpdatesOn){
            locationManager.startMonitoringSignificantLocationChanges()
        } else{
            locationManager.stopMonitoringSignificantLocationChanges();
        }
    }

    func startLocationUpdates() {
        print("start Location Updates()")
        locationManager.startUpdatingLocation()
    }
    
    func updatesAreOn() -> Bool{
        return updating;
    }    
    
    func stopLocationUpdates(){
        locationManager.allowsBackgroundLocationUpdates = false;
        locationManager.stopMonitoringSignificantLocationChanges();
        locationManager.stopUpdatingLocation()

        print("Stop location updates")
        updating = false;
        delegate?.didStopLocationUpdates?();
    }
}
