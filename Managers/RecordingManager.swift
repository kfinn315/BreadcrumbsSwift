//
//  RecordingManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/5/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation


public class RecordingManager {
    private weak var crumbsManager = CrumbsManager.shared
    private var LocationManager = CoreLocationManager()
    private var disposeBag = DisposeBag()
    private var startTime : Date?
    private var stopTime : Date?
    
    static private var _shared : RecordingManager?
    static var shared : RecordingManager {
        get{
            if _shared == nil {
                _shared = RecordingManager()
            }
            
            return _shared!
        }
    }
    
    private init() {
        LocationManager.location
            .drive(onNext: { [unowned self] (cllocation : CLLocation) in
                //this is called when there's a new location
                print("location manager didUpdateLocations");
                
                self.crumbsManager?.addPointToData(LocalPoint.from(cllocation))
            }).disposed(by: disposeBag)
    }
    
    public func startUpdating(with accuracy: LocationAccuracy = .walking){
        startTime = Date()
        stopTime = nil
        crumbsManager!.clearPoints()
        LocationManager.startLocationUpdates(with: accuracy);
    }
    
    public func stopUpdating(){
        stopTime = Date()
        LocationManager.stopLocationUpdates();
    }
    
    public func save(){
        crumbsManager?.SaveNewPath(start: startTime ?? Date(), end: stopTime ?? Date(), title: "", notes: "");
    }
    
    public func reset(){
        crumbsManager?.clearPoints();
    }
    
    public var isRecording : Bool {
        return LocationManager.isUpdating
    }
}
