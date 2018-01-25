//
//  NewPathViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/11/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import CoreData
import CloudKit
import RxCocoa
import RxSwift

public class NewPathViewController : UITableViewController, CLLocationManagerDelegate, CrumbsDelegate {
    var LocationManager = CoreLocationManager()
    var crumbsManager : CrumbsManager?
    var SaveAlert : UIAlertController?
    var recording = false
    var disposeBag = DisposeBag()
    //var path : Path?
    var startTime : Date?
    var stopTime : Date?
    
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var tfTitle: UITextField!
    
    @IBOutlet weak var tfNotes: UITextField!
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        crumbsManager = CrumbsManager.shared
        
        self.SaveAlert = UIAlertController(title: "Save?", message: "Would you like to save this path or reset?", preferredStyle: UIAlertControllerStyle.alert)
        let actionSave = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonSaveClicked()})
        let actionReset = UIAlertAction.init(title: "Reset", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.buttonResetClicked()})
        self.SaveAlert?.addAction(actionSave)
        self.SaveAlert?.addAction(actionReset)
        
        self.btnRecord.rx.tap.subscribe({ _ in self.buttonStartStopClicked()}).disposed(by: disposeBag)
        LocationManager.location
            .drive(onNext: { [unowned self] (cllocation : CLLocation) in
                //this is called when there's a new location
                print("location manager didUpdateLocations");
                
                self.crumbsManager!.addPointToData(Point.from(cllocation))
                
            }).disposed(by: disposeBag)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        recording = false
        
        //LocationManager.delegate = self;
        crumbsManager?.delegate = self;
        
        if LocationManager.updatesAreOn() {
            recording = true
            btnRecord.titleLabel?.text = "Stop";
        } else{
            btnRecord.titleLabel?.text = "Record";
        }
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        tableView.reloadData()
    }
    
    func buttonSaveClicked(){
        LocationManager.stopLocationUpdates();
        
        crumbsManager!.SaveNewPath(start: startTime, end: stopTime, title: tfTitle.text ?? "", description: tfNotes.text );
    }
    
    func buttonDoneClicked(){
        stopUpdating();
        self.dismiss(animated: true, completion: nil)
    }
    
    func buttonStartStopClicked(){
        if recording {
            stopTime = Date()
            stopUpdating()
        }
        else{
            startTime = Date()
            startUpdating();
        }
    }
    
    private func stopUpdating(){
        recording = false
        LocationManager.stopLocationUpdates();
        btnRecord.setTitle("Record", for: .normal)
        
        if let alertcontroller = SaveAlert{
            present(alertcontroller, animated: true)
        }
    }
    
    private func startUpdating(){
        recording = true
        btnRecord.setTitle("Stop", for: .normal)
        
        crumbsManager!.clearPoints()
        
        LocationManager.startLocationUpdates();
    }
    
    func buttonResetClicked(){
       crumbsManager!.clearPoints();        
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
