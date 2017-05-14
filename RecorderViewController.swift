//
//  RecorderController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/22/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreLocation
import MapKit
import CoreData

class RecorderViewController : UIViewController, MKMapViewDelegate, CoreLocationDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var labelB: UILabel!
    @IBOutlet weak var SaveBTN: UIButton!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    
    var LocationManager : CoreLocationManager?;
    
    var crumbsManager = CrumbsManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        SaveBTN.addTarget(self, action: #selector(self.buttonSaveClicked), for: .touchUpInside)
        btnStart.addTarget(self, action: #selector(self.buttonStartStopClicked), for: .touchUpInside)
        btnReset.addTarget(self, action: #selector(self.buttonResetClicked), for: .touchUpInside)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        LocationManager = CoreLocationManager();
        LocationManager?.delegate = self;

        mapView.showsUserLocation = true;
        
        if(LocationManager?.updatesAreOn())!{
            btnStart.titleLabel?.text = "Stop";
        } else{
            btnStart.titleLabel?.text = "Start";
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
            
    func buttonRecordClicked(){
        if #available(iOS 10.0, *) {
            crumbsManager.clearPoints()
        } else {
            // Fallback on earlier versions
        }
        
        LocationManager?.startLocationUpdates();
    }
    func buttonStartStopClicked(){
        if(LocationManager?.updatesAreOn())!{
            stopUpdating()
        }
        else{
            startUpdating();
        }
    }
    
    func stopUpdating(){
        LocationManager?.stopLocationUpdates();
    }
    func startUpdating(){
        if #available(iOS 10.0, *) {
            crumbsManager.clearPoints()
        } else {
            // Fallback on earlier versions
        }
        
        LocationManager?.startLocationUpdates();
    }
    func buttonSaveClicked(){
        LocationManager?.stopLocationUpdates();
        
        let mycrumb = Crumb();
        mycrumb.Title = String(describing: Date())
        mycrumb.Description = "description ";
        
        self.SaveCrumb(crumb:mycrumb)
    }
    
    func SaveCrumb(crumb:Crumb){
        print("saveCrumb")
        
        crumbsManager.SaveCurrentPath();
        mapView.removeAnnotations(mapView.annotations);
        
    }
    
    func buttonResetClicked(){
        crumbsManager.clearPoints();
        mapView.removeAnnotations(mapView.annotations);
    }
    
    //delegate callbacks
    func errorUpdatingLocations(_ Error: NSError) {
         print("Could not update locations. \(Error), \(Error.userInfo)")
    }
    
    func didUpdateLocations(manager: CLLocationManager, locations: [CLLocation]) {
        let point = locations.last;
        let annotation = MKPointAnnotation();
        annotation.coordinate = (point?.coordinate)!;
        annotation.title = String(describing: point?.coordinate.latitude)+","+String(describing: point?.coordinate.longitude);
        mapView.addAnnotation(annotation);
        mapView.setCenter((point?.coordinate)!, animated: false)
        labelA.text = "Location: "+String(describing: point?.coordinate.latitude)+","+String(describing: point?.coordinate.longitude);
//        labelB.text = "Points: "+String(describing: points);
        
        crumbsManager.addPointToData(point: point)
        
    }
    
    
    internal func savedCrumb(Id: CKRecordID) {
        
    }

    func didStopLocationUpdates() {
        btnStart.setTitle("Start", for: .normal);
    }
    
    func didStartLocationUpdates() {
        btnStart.setTitle("Stop", for: .normal);
    }
}
