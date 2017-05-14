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

class MapViewController: UIViewController, MKMapViewDelegate, CloudKitDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var crumbs :Array<Crumb>!
    var strokeColor = UIColor.red;
    var lineWidth = CGFloat(2.0);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        CloudKitManager.sharedInstance.delegate = self;
    }
    override func viewWillAppear(_ animated: Bool) {
        print("GetCrumbData->GetCrumbPaths");
        CloudKitManager.GetCrumbPaths();
        //GetCrumbData();
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = strokeColor;
        renderer.lineWidth = lineWidth;
        
        return renderer
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
            
            
            self.mapView.setNeedsLayout();
            
            print("GetCrumbData-> mapView.setNeedsLayout()");
            
        }
    }
    
    func CrumbSaved(_ Id: CKRecordID) {
    }

    func errorUpdatingCrumbs(_ Error: NSError) {
        
    }
    
    func CrumbsReset(){}
}

