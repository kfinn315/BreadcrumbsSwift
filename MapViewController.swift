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
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnRecord: UIBarButtonItem!
    
    var crumbs :Array<Crumb>!
       var mapManager : MapViewManager?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CloudKitManager.sharedInstance.delegate = self;
        
        btnMenu.action = #selector(ToggleMenu)
        mapManager = MapViewManager(map: mapView);
    }
    
    func ToggleMenu(){
        (self.parent as! ContainerViewController).toggleLeft()
    }
    
    //load crumb and display
    public func LoadCrumb(path: Crumb){
        ClearMap();
        AddLine(crumb: path);
        mapManager?.ZoomToFit();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("GetCrumbData->GetCrumbPaths");
        CloudKitManager.GetCrumbPaths();
        //GetCrumbData();
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func CrumbsLoaded(_ Crumbs: Array<Crumb>) {
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
    
    func ClearMap(){
        mapView.removeAnnotations(mapView.annotations);
        mapView.removeOverlays(mapView.overlays)
    }
    
    func AddLine(crumb: Crumb){
        var locations = Array<CLLocation>();
        
        for point in crumb.Path{
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
}

