//
//  MyLocationManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/30/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

public enum LocationAccuracy : Int {
    case walking
    case running
    case biking
    case driving
    case custom
}

class CoreLocationManager: NSObject, CLLocationManagerDelegate {
    static let sharedInstance = CoreLocationManager()
    weak var delegate : CoreLocationDelegate?
    public var authorized : Driver<Bool>
    public var location : Driver<CLLocation>
    private var updating = false
    var disposeBag = DisposeBag()
    
    public let locationManager = CLLocationManager()
    
    internal override init() {
        locationManager.delegate = nil
        
        weak var weakLocationManager = locationManager
        
        authorized = Observable.deferred {
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
        
        if(LocationSettings.significantUpdatesOn && !CLLocationManager.significantLocationChangeMonitoringAvailable()) {
            LocationSettings.significantUpdatesOn  = false
        }
        
        //locationManager.delegate = self;
//        updateSettings()
    }

    private func updateSettings(_ accuracy: LocationAccuracy) {
        switch accuracy {
        case .walking:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 50.0 //meters
        case .running:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 50.0 //meters
        case .biking:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 100.0
        case .driving:
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 1000.0 //meters
        case .custom:
            locationManager.desiredAccuracy = LocationSettings.locationAccuracy
            locationManager.distanceFilter = LocationSettings.minimumDistance
        }
        
        locationManager.allowsBackgroundLocationUpdates = LocationSettings.backgroundLocationUpdatesOn
        if(LocationSettings.significantUpdatesOn) {
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
    }

    func startLocationUpdates(with accuracy: LocationAccuracy = .walking) {
        updateSettings(accuracy)
        
        updating = true
        print("start Location Updates()")
        locationManager.startUpdatingLocation()
    }
    
    public var isUpdating : Bool {
        return updating
    }    
    
    func stopLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()

        print("Stop location updates")
        updating = false
        delegate?.didStopLocationUpdates?()
    }
}
