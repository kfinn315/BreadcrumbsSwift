//
//  ViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class MapViewController: UIViewController, CloudKitDelegate {
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var mapManager : MapViewManager?;
    var container : ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapManager = MapViewManager(map: mapView);
        
        self.container = (self.parent?.parent as! ContainerViewController);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = self;
        
        buttonShare.addTarget(self, action: #selector(sharePath), for: .touchDown)
    }
    
    func sharePath(){
        do{
            if let record = container?.GetMainCrumb()?.Record{
                try CloudKitManager.SetPublicPath(record: record, share: buttonShare.titleLabel?.text=="Share")
            }
        } catch{
            
        }
    }
    
    @IBAction public func ToggleMenu(){
        (self.parent?.parent as! ContainerViewController).toggleLeft()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationItem.leftBarButtonItem?.action = #selector(ToggleMenu)
        //navigationController?.navigationItem.rightBarButtonItem?.action = #selector(showRecordView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func showRecordView(){
        navigationController?.present(RecorderViewController(), animated: true, completion: nil)
    }
    //load main crumb and display
    public func LoadCrumb(path: PathsType){
        ClearMap();
        self.navigationController?.navigationItem.title = path.GetTitle()
        setShared(path.GetIsShared());
        
        AddLine(crumb: path);
        mapManager?.ZoomToFit();
        
        CrumbsManager.CurrentCrumb = path;
    }
    
    func setShared(_ isShared: Bool){
        if(isShared){
            buttonShare.backgroundColor = UIColor.yellow;
            buttonShare.setTitle( "Unshare", for: UIControlState.normal)
        } else{
            buttonShare.backgroundColor = UIColor.clear;
            buttonShare.setTitle("Share", for: UIControlState.normal)
        }
    }
    
    func ClearMap(){
        mapView.removeAnnotations(mapView.annotations);
        mapView.removeOverlays(mapView.overlays)
    }
    
    func AddLine(crumb: PathsType){
        var locations = Array<CLLocation>();
        
        for point in crumb.GetPoints()!{
            locations.append(point);
            let annotation = MKPointAnnotation();
            annotation.coordinate = point.coordinate;
            annotation.title = String(point.coordinate.latitude)+","+String(point.coordinate.longitude);
            self.mapView.addAnnotation(annotation);
        }
        
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        
        self.mapView.add(polyline)
    }
    func CrumbSaved(_ Id: CKRecordID) {
    }
    
    func errorUpdatingCrumbs(_ Error: Error) {
        
    }
    func errorSavingData(_ Error: Error) {
        
    }
    func CrumbsReset(){}
    func CrumbDeleted(_ RecordID: CKRecordID) {
        
    }
    func CrumbsUpdated(_ Crumbs: Array<PathsType>) {
        DispatchQueue.main.async {
            //self.userpaths = Crumbs;
            print("GetCrumbData->update map w/ "+String(Crumbs.count)+" crumbs");
            
            for path in Crumbs{
                self.AddLine(crumb: path)
            }
            self.mapView.setNeedsLayout();
            self.mapManager?.ZoomToFit();
            
            print("GetCrumbData-> mapView.setNeedsLayout()");
            
        }
        
    }
}

