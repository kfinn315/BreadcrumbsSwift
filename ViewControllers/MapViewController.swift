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
    let lineTolerance : Float = 0.000005
    let annotationLatDelta : CLLocationDistance = 0.010
    let strokeColor = UIColor.red
    let lineWidth = CGFloat(2.0)
    var disposeBag = DisposeBag()
    let pinAnnotationImageView = UIImage.circle(diameter: CGFloat(10), color: UIColor.orange)
    
    @IBOutlet weak var mapView: MKMapView!
    
    private weak var path : Path?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        CrumbsManager.shared.currentPathDriver?.drive(onNext: { [weak self] path in
            self?.path = path
            if path != nil {
                DispatchQueue.main.async {
                    self?.loadCrumb(path: path!)
                }
            }
        }).disposed(by: disposeBag)
        
        CrumbsManager.shared.currentPathAlbum.asObservable().subscribe(onNext: {[weak self] collection in
            if let collectionImages = collection {
                self?.AddImageAnnotations(collectionImages)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        mapView.delegate = nil
    }
    
    func AddImageAnnotations(_ assets: [PHAsset]) {
        DispatchQueue.global(qos: .userInitiated).async {
            var annotations : [ImageAnnotation] = []
            for asset in assets {
                if let loc = asset.location {
                    PHImageManager.default().requestImage(for: asset, targetSize: CGSize.init(width: 50, height: 50), contentMode: .aspectFit, options: nil, resultHandler: { (img, _) in
                        let annotation = ImageAnnotation()
                        annotation.coordinate = loc.coordinate
                        annotation.title = asset.creationDate?.string ?? ""
                        annotation.image = img
                        annotations.append(annotation)
                    })
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.mapView.addAnnotations(annotations)
            }
        }
    }
    
    // MARK: - from manager
    
    //load crumb and display
    public func loadCrumb(path: Path) {
        clearMap()
        
        addLine(crumb: path)
       // ZoomToFit()
    }
    
    func clearMap() {
        mapView?.removeAnnotations((mapView?.annotations)!)
        mapView?.removeOverlays((mapView?.overlays)!)
    }
    
    func zoomToPoint(_ point: CLLocation, animated: Bool) {
        var zoomRect = MKMapRectNull
        let mappoint = MKMapPointForCoordinate(point.coordinate)
        let pointRect = MKMapRectMake(mappoint.x, mappoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
        mapView?.setVisibleMapRect(zoomRect, animated: true)
    }
    
    func zoomToFit() {
        mapView?.setVisibleMapRect(getZoomRect(from: mapView.annotations), animated: true)
    }
    
    private func getZoomRect(from annotations: [MKAnnotation]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        return zoomRect
    }
    private func getZoomRect(from coords: [CLLocationCoordinate2D]) -> MKMapRect {
        var zoomRect = MKMapRectNull
        
        for coord in coords {
            let point = MKMapPointForCoordinate(coord)
            let pointRect = MKMapRectMake(point.x, point.y, 0.1, 0.1)
            zoomRect = MKMapRectUnion(zoomRect, pointRect)
        }
        
        return MKMapRectInset(zoomRect, -5.0, -5.0)
    }
    
    func addAnnotation(point: CLLocationCoordinate2D, title: String) {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = point
        annotation.title = title
        
        mapView?.setCenter(point, animated: false)
    }
    
    func addLine(crumb: Path) {
        let points = crumb.getPoints()
        
        var coordinates = points.map({(point: Point) -> CLLocationCoordinate2D in return point.coordinates})
        
        if coordinates.count > 5 {
        //simplify coordinates
            coordinates = SwiftSimplify.simplify(coordinates, tolerance: lineTolerance)
        }
        
        //add annotation to first and last coords
        if let firstcoord = coordinates.first {
            let firstpin = MKPointAnnotation()
            firstpin.coordinate = firstcoord
            self.mapView?.addAnnotation(firstpin)
        }
        if coordinates.count > 1, let lastcoord = coordinates.last {
            let lastpin = MKPointAnnotation()
            lastpin.coordinate = lastcoord
            self.mapView?.addAnnotation(lastpin)
        }
        
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        setVisibleMapArea(polyline: polyline, edgeInsets: UIEdgeInsetsMake(25.0,25.0,25.0,25.0))
        self.mapView?.add(polyline)
    }
    
    func setVisibleMapArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
    
    // MARK: - MapViewDelegate implementation

    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = strokeColor
        renderer.lineWidth = lineWidth
        
        return renderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is ImageAnnotation, let imgAnnotation = annotation as? ImageAnnotation {
            return imgAnnotation.getPinView()
        } else {
            let view = MKAnnotationView()
            view.image = pinAnnotationImageView
            return view
        }
    }
    
//    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        var showAnnotations = true
//
//        if mapView.region.span.latitudeDelta > ANNOTATION_LAT_DELTA || mapView.camera.altitude > 1400.0 {
//            showAnnotations = false
//        }
//
//        for annotation in mapView.annotations
//        {
//                mapView.view(for: annotation)?.isHidden = !showAnnotations
//        }
//    }
    
    public func getSnapshot(_ callback: @escaping MKMapSnapshotCompletionHandler) {
        let options = MKMapSnapshotOptions()
        if #available(iOS 11.0, *) {
            options.mapType = MKMapType.mutedStandard
        } else {
            // Fallback on earlier versions
        }
        if let points = CrumbsManager.shared.currentPath?.getPoints() {
            let coordinates = points.map({(point: Point) -> CLLocationCoordinate2D in return point.coordinates})
            options.mapRect = getZoomRect(from: coordinates)
        }
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { (snapshot, error) in
            //draw on img here
            callback(snapshot, error)
        }
    }
}

class ImageAnnotation : MKPointAnnotation {
    var image : UIImage?
    
    override init() {
        super.init()
    }
    
    public func getPinView() -> MKPinAnnotationView {
        let pin = MKPinAnnotationView(annotation: self, reuseIdentifier: "imagePin")
        pin.pinTintColor = UIColor.darkGray
        pin.canShowCallout = true
        pin.animatesDrop = true
        pin.leftCalloutAccessoryView = UIImageView(image: image)
        return pin
    }
}
