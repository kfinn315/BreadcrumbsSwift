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
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnRecord: UIBarButtonItem!
    
    var crumbs :Array<PathsType>!
    var mapManager : MapViewManager?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnMenu.action = #selector(ToggleMenu)
        mapManager = MapViewManager(map: mapView);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = self;
        
        crumbs = CloudKitManager.sharedInstance.crumbs;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CloudKitManager.sharedInstance.delegate = nil;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //load crumb and display
    public func LoadCrumb(path: PathsType){
        ClearMap();
        navBar.topItem?.title = path.GetTitle()
        AddLine(crumb: path);
        mapManager?.ZoomToFit();
    }

    func ToggleMenu(){
        (self.parent as! ContainerViewController).toggleLeft()
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
            self.crumbs = Crumbs;
            print("GetCrumbData->update map w/ "+String(self.crumbs.count)+" crumbs");
            
            for crumb in self.crumbs{
                self.AddLine(crumb: crumb)
            }
            self.mapView.setNeedsLayout();
            self.mapManager?.ZoomToFit();
            
            print("GetCrumbData-> mapView.setNeedsLayout()");
            
        }

    }
}

