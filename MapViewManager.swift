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

    public override init(){ }
    
    public convenience init(map: MKMapView)
    {
        self.init()
        
        mapView = map;
        mapView?.delegate = self;
    }
    
    deinit {
        mapView?.delegate = nil;
    }
    
    //load crumb and display
    public func LoadCrumb(path: Path){
        ClearMap();
        AddLine(crumb: path);
        ZoomToFit();
    }
    
    
    func ClearMap(){
        mapView?.removeAnnotations((mapView?.annotations)!);
        mapView?.removeOverlays((mapView?.overlays)!)
    }
    
    func ZoomToPoint(_ Point: CLLocation, animated: Bool){
        var zoomRect = MKMapRectNull;
        let mappoint = MKMapPointForCoordinate(Point.coordinate);
        let pointRect = MKMapRectMake(mappoint.x, mappoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
        mapView?.setVisibleMapRect(zoomRect, animated: true);
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
    
    func AddAnnotation(Point: CLLocationCoordinate2D, Title: String){
      //  let point = Location;//locations.last;
        let annotation = MKPointAnnotation();
        
        annotation.coordinate = Point
        annotation.title = Title;
        
        mapView?.setCenter(Point, animated: false)
    }
    
    func AddLine(crumb: Path){
        var locations = Array<Point>();
        
        let points = crumb.getPoints()
        for point in points{
            locations.append(point);
            let annotation = MKPointAnnotation();
            annotation.coordinate = point.coordinates
            annotation.title = crumb.title
            self.mapView?.addAnnotation(annotation);
        }
        
        var coordinates = locations.map({(point: Point) -> CLLocationCoordinate2D in return point.coordinates})
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
        if annotation is ImageAnnotation {
            let imageA = annotation as! ImageAnnotation
            return imageA.getPinView()
        } else {
            let view = MKAnnotationView()
            view.image = UIImage.circle(diameter: CGFloat(10),color: UIColor.orange);
            return view;
        }
    }
}
