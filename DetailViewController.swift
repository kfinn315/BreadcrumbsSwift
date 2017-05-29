//
//  NavRootViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/17/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit

///not used
class DetailViewController: UIViewController, MKMapViewDelegate{
    @IBOutlet weak var detailLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var crumb = Crumb();
    var strokeColor = UIColor.red;
    var lineWidth = CGFloat(2.0);
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        detailLbl.text = crumb.Title;
        
        var locations = Array<CLLocation>();
        
        for point in crumb.Path{
            locations.append(point);
            let annotation = MKPointAnnotation();
            annotation.coordinate = point.coordinate;
            annotation.title = String(point.coordinate.latitude)+","+String(point.coordinate.longitude);
            mapView.addAnnotation(annotation);
        }
        
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        
        self.mapView.add(polyline)
        if(crumb.Path.first != nil){
            self.mapView.setCenter((crumb.Path.first?.coordinate)!, animated: true)
        }

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

}

