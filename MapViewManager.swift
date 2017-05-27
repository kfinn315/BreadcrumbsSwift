//
//  MapViewManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/26/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import MapKit

public class MapViewManager : NSObject, MKMapViewDelegate{
    
    var mapView : MKMapView?
    var strokeColor = UIColor.red;
    var lineWidth = CGFloat(2.0);

    public override init(){
        
    }
    
    public convenience init(map: MKMapView)
    {
        self.init()
        
        mapView = map;
        mapView?.delegate = self;
    }
    
    
    //load crumb and display
    public func LoadCrumb(path: Crumb){
        ClearMap();
        AddLine(crumb: path);
        ZoomToFit();
    }
    
    
    func ClearMap(){
        mapView?.removeAnnotations((mapView?.annotations)!);
        mapView?.removeOverlays((mapView?.overlays)!)
    }
    
    
    func ZoomToFit(){
        var zoomRect = MKMapRectNull;
        for annotation in (mapView?.annotations)!
        {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        mapView?.setVisibleMapRect(zoomRect, animated: true);
    }
    
    
    func AddLine(crumb: Crumb){
        var locations = Array<CLLocation>();
        
        for point in crumb.Path{
            locations.append(point);
            let annotation = MKPointAnnotation();
            annotation.coordinate = point.coordinate;
            annotation.title = String(point.coordinate.latitude)+","+String(point.coordinate.longitude);
            self.mapView?.addAnnotation(annotation);
        }
        
        var coordinates = locations.map({(location: CLLocation) -> CLLocationCoordinate2D in return location.coordinate})
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        
        self.mapView?.add(polyline)
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = strokeColor;
        renderer.lineWidth = lineWidth;
        
        return renderer
    }
    
    //delegate callbacks
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView()
        view.image = UIImage.circle(diameter: CGFloat(10),color: UIColor.orange);
        return view;
    }
    

}
