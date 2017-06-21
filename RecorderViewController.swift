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

class RecorderViewController : UIViewController, CoreLocationDelegate, CLLocationManagerDelegate, CrumbsDelegate{

//    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var mapView: MKMapView!
  //  @IBOutlet weak var labelA: UILabel!
  //  @IBOutlet weak var labelB: UILabel!
  //  @IBOutlet weak var SaveBTN: UIButton!
//    @IBOutlet weak var btnReset: UIButton!
//    @IBOutlet weak var btnSettings: UIBarButtonItem!
    
    var LocationManager : CoreLocationManager?;
    var crumbsManager = CrumbsManager();
    var MapManager = MapViewManager();
    var SaveAlert : UIAlertController?;
    
    init(_ coder: NSCoder? = nil) {
        
        if let coder = coder {
            super.init(coder: coder)!
        } else {
            super.init(nibName: nil, bundle:nil)
        }
        
        self.SaveAlert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonSaveClicked()})
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonResetClicked()})
        self.SaveAlert?.addAction(actionSave)
        self.SaveAlert?.addAction(actionReset)
     
        
    }
    
    required convenience init(coder: NSCoder) {
        self.init(coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        
       // SaveBTN.addTarget(self, action: #selector(self.buttonSaveClicked), for: .touchUpInside)
        btnStart.addTarget(self, action: #selector(self.buttonStartStopClicked), for: .touchUpInside)
    //    btnReset.addTarget(self, action: #selector(self.buttonResetClicked), for: .touchUpInside)
//        btnDone.action = #selector(self.buttonDoneClicked)
        
        navigationController?.navigationItem.rightBarButtonItem?.action = #selector(self.buttonSettingsClicked)
        
        mapView.showsUserLocation = true;
        LocationManager = CoreLocationManager();

    }

    override func viewWillAppear(_ animated: Bool) {
        MapManager.mapView = self.mapView
        LocationManager?.delegate = self;
        crumbsManager.delegate = self;
          
        if(LocationManager?.updatesAreOn())!{
            btnStart.titleLabel?.text = "Stop";
        } else{
            btnStart.titleLabel?.text = "Start";
        }
        
        if let number = CoreLocationManager.LManager?.location {
            MapManager.ZoomToPoint(number, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        LocationManager?.delegate = nil;
        crumbsManager.delegate = nil;
    }
    func buttonDoneClicked(){
        stopUpdating();
        self.dismiss(animated: true, completion: nil)
    }
    
    func buttonSettingsClicked(){
        navigationController?.present(SettingsViewController(), animated: true, completion: nil)
    }
    
    func buttonStartStopClicked(){
        if(LocationManager?.updatesAreOn())!{
            stopUpdating()
        }
        else{
            startUpdating();
        }
    }
    
    private func stopUpdating(){
        LocationManager?.stopLocationUpdates();
    }
    
    private func startUpdating(){
        do{
            try crumbsManager.clearPoints()
        } catch{
            //show error
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
    
    private func SaveCrumb(crumb:Crumb){
        print("saveCrumb")
        
        do{
            try crumbsManager.SaveCurrentPath();
        } catch{
            //show error
        }
        MapManager.ClearMap()
        
    }
    
    func buttonResetClicked(){
        do{
            try crumbsManager.clearPoints();
        } catch{
            //show error
        }
        
        MapManager.ClearMap()
    }
    
    //delegate callbacks
    func errorUpdatingLocations(_ Error: Error) {
         print("Could not update locations. \(Error), \(Error.localizedDescription)")
        
        let alert = UIAlertController(title: "Error", message: Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorSavingData(_ Error: Error) {
        print("Could not save data. \(Error), \(Error.localizedDescription)")
        let alert = UIAlertController(title: "Error", message: Error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didUpdateLocations(manager: CLLocationManager, locations: [CLLocation]) {
        let point = locations.last;
        let title = String(describing: point?.coordinate.latitude)+","+String(describing: point?.coordinate.longitude);

        MapManager.AddAnnotation(Point: point!, Title: title);
        
        do{
            try crumbsManager.addPointToData(point: point)
        } catch{
            //show error
        }
    }
    
    func didStopLocationUpdates() {
        if(btnStart.titleLabel?.text == "Stop"){
            btnStart.setTitle("Start", for: .normal);
        
            if let alertcontroller = SaveAlert{
                present(alertcontroller, animated: true)
            }
        }
        
    }
    
    func didStartLocationUpdates() {
        btnStart.setTitle("Stop", for: .normal);
    }
    func CrumbsLoaded(_ Crumbs: Array<PathsType>) {
    }
    func CrumbsUpdated(_ Crumbs: Array<PathsType>) {
        //self.dismiss(animated: true, completion: nil)
    }
    func CrumbSaved(_ Id: CKRecordID) {
        self.dismiss(animated: true, completion: nil)
    }
    func CrumbsReset() {
    }
    
    func errorUpdatingCrumbs(_ Error: Error){}
    
    
}
