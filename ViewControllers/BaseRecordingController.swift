//
//  RecordViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/7/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import CloudKit
import RxCocoa
import RxSwift

public class BaseRecordingController : UIViewController,CLLocationManagerDelegate {
    weak var crumbsManager = CrumbsManager.shared
    var locationManager = CoreLocationManager()
    var disposeBag = DisposeBag()
    var startTime : Date?
    var stopTime : Date?
    var isRecording : Bool = false

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.location
            .drive(onNext: { [unowned self] (cllocation : CLLocation) in
                //this is called when there's a new location
                log.debug("location manager didUpdateLocations")
                
                self.crumbsManager?.addPointToData(LocalPoint.from(cllocation))
            }).disposed(by: disposeBag)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //delegate callbacks
    func errorUpdatingLocations(_ error: Error) {
        log.error("Could not update locations. \(error), \(error.localizedDescription)")
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorSavingData(_ error: Error) {        
        log.error("Could not save data. \(error), \(error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func crumbSaved(error: Error?) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func startUpdating(accuracy: LocationAccuracy) {
       // let accuracy = LocationAccuracy(rawValue: segAction.selectedSegmentIndex) ?? LocationAccuracy.walking
        
        crumbsManager!.clearPoints()
        
        locationManager.startLocationUpdates(with: accuracy)
        
        startTime = Date()
        stopTime = nil
    }
    
    public func stopUpdating() {
        stopTime = Date()
        locationManager.stopLocationUpdates()
    }
    
    public func save(callback: @escaping (Path?,Error?) -> Void) {
        crumbsManager?.saveNewPath(start: startTime ?? Date(), end: stopTime ?? Date(), title: "", notes: "", callback: callback)
    }
    
    public func reset() {
        crumbsManager?.clearPoints()
    }
//    
//    public var isRecording : Bool {
//        return locationManager.isUpdating
//    }
}
