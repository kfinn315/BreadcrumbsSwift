//
//  MapViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import Photos
import RxSwift
import RxCocoa
import SwiftSimplify

class MapViewController: UIViewController, MKMapViewDelegate {
    let LINE_TOLERANCE : Float = 0.000005
    let ANNOTATION_LAT_DELTA : CLLocationDistance = 0.010
    let strokeColor = UIColor.red
    let lineWidth = CGFloat(2.0)

    @IBOutlet weak var mapView: MKMapView!
    
    var disposeBag = DisposeBag()
    
    private weak var path : Path?
   // private var mapManager : MapViewManager?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // mapManager = MapViewManager(map: mapView);
        
        mapView.delegate = self
        
        CrumbsManager.shared.currentPath.asObservable().subscribe(onNext: { [weak self] path in
            self?.path = path
            if path != nil {
                self?.LoadCrumb(path: path!)
            }
        }).disposed(by: disposeBag)
        
        CrumbsManager.shared.currentPathAlbum.asObservable().subscribe(onNext: {[weak self] collection in
            if let collectionImages = collection {
                self?.AddImagePoints(collectionImages)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func AddImagePoints(_ assets: [PHAsset]){
        DispatchQueue.global(qos: .userInitiated).async{
            for asset in assets {
                if let loc = asset.location {
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize.init(width: 50, height: 50), contentMode: .aspectFit, options: nil, resultHandler: {
                        [weak self] (img, dict) in
                        let annotation = ImageAnnotation()
                        annotation.coordinate = loc.coordinate
                        annotation.title = asset.creationDate?.datestring ?? ""
                        annotation.image = img

                        DispatchQueue.main.async {
                            self?.mapView.addAnnotation(annotation)
                        }
                    })
                }
            }
        }
    }
    
    //MARK:-from manager
    
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
        let annotation = MKPointAnnotation();
        
        annotation.coordinate = Point
        annotation.title = Title;
        
        mapView?.setCenter(Point, animated: false)
    }
    
    func AddLine(crumb: Path){
        let points = crumb.getPoints()
        
        let coordinates = points.map({(point: Point) -> CLLocationCoordinate2D in return point.coordinates})
        
        var simplecoordinates = SwiftSimplify.simplify(coordinates, tolerance: LINE_TOLERANCE)
        
        for coordinate in simplecoordinates{
            let annotation = MKPointAnnotation();
            annotation.coordinate = coordinate
            //annotation.title = crumb.title
            self.mapView?.addAnnotation(annotation);
        }
        
        let polyline = MKPolyline(coordinates: &simplecoordinates, count: simplecoordinates.count)
        
        self.mapView?.add(polyline)
    }
    
    //MARK:- MapViewDelegate implementation

    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = strokeColor;
        renderer.lineWidth = lineWidth;
        
        return renderer
    }
    
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
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var showAnnotations = true
        
        if mapView.region.span.latitudeDelta > ANNOTATION_LAT_DELTA || mapView.camera.altitude > 1400.0 {
            showAnnotations = false
        }
        
        for annotation in mapView.annotations
        {
            if showAnnotations {
                mapView.view(for: annotation)?.isHidden = false
            }
            else {
                mapView.view(for: annotation)?.isHidden = true
            }
        }
    }
}

class ImageAnnotation : MKPointAnnotation {
    var image : UIImage?
    
    override init(){
        super.init()
    }
    
    public func getPinView() -> MKPinAnnotationView{
        let pin = MKPinAnnotationView(annotation: self, reuseIdentifier: "imagePin")
        pin.pinTintColor = UIColor.darkGray
        pin.canShowCallout = true
        pin.animatesDrop = true
        pin.leftCalloutAccessoryView = UIImageView(image: image)
        return pin
    }
}

