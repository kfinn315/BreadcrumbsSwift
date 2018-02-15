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
    static let lineTolerance : Float = 0.000005
    static let annotationLatDelta : CLLocationDistance = 0.010
    static let strokeColor = UIColor.red
    static let lineWidth = CGFloat(2.0)
    static let pinAnnotationImageView = UIImage.circle(diameter: CGFloat(10), color: UIColor.orange)
    private var disposeBag = DisposeBag()
    
    fileprivate let imageManager = PHCachingImageManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    private weak var path : Path?
    private weak var crumbsManager = CrumbsManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("mapview did load")
        
        crumbsManager?.currentPathDriver?.drive(onNext: { [weak self] path in
            log.debug("mapview current path driver - on next")
            
            self?.loadCrumb(path: path)
        }).disposed(by: disposeBag)
        
        crumbsManager?.currentAlbumDriver.drive(onNext: {[weak self] collection in
            log.debug("mapview current album driver - on next")
            
            if let collectionImages = collection {
                self?.AddImageAnnotations(collectionImages)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        
        log.debug("mapview will appear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.delegate = nil
        
        log.debug("mapview will disappear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        log.debug("mapview received memory warning")
        
    }
    let thumbnailSize = CGSize(width: 50, height: 50)
    func AddImageAnnotations(_ collection: PHAssetCollection) {
        log.debug("mapview add image annotations")
        log.debug("current annotations \(mapView.annotations.count)")
        
        let fetchresults = PHAsset.fetchAssets(in: collection, options: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            var annotations : [ImageAnnotation] = []
            fetchresults.enumerateObjects({ (asset, startindex, end) in
                if let loc = asset.location {
                    let annotation = ImageAnnotation()
                    annotation.coordinate = loc.coordinate
                    annotation.asset = asset
                    annotation.title = "omg"
                    annotations.append(annotation)
                }
            })
            DispatchQueue.main.async { [weak self] in
                self?.mapView.addAnnotations(annotations)
            }
        }
    }
    
    public func loadCrumb(path: Path?) {
        log.debug("mapview loadcrumb")
        clearMap()
        addLine(coordinates: path?.getPoints() ?? [])
        zoomToFit()
    }
    
    func clearMap() {
        log.debug("mapview clear map")
        mapView?.removeAnnotations((mapView?.annotations)!)
        mapView?.removeOverlays((mapView?.overlays)!)
    }
    
    func zoomToPoint(_ point: CLLocation, animated: Bool) {
        log.debug("mapview zoom to point")
        var zoomRect = MKMapRectNull
        let mappoint = MKMapPointForCoordinate(point.coordinate)
        let pointRect = MKMapRectMake(mappoint.x, mappoint.y, 0.1, 0.1)
        zoomRect = MKMapRectUnion(zoomRect, pointRect)
        mapView?.setVisibleMapRect(zoomRect, animated: true)
    }
    
    func zoomToFit() {
        log.debug("mapview zoom to fit")
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
        //mapView?.setCenter(point, animated: false)
    }
    
    func addLine(coordinates: [CLLocationCoordinate2D]) {
        // let points = points.getPoints()
        var simpleCoords : [CLLocationCoordinate2D]?
        
        if coordinates.count > 5 {
            //simplify coordinates
            simpleCoords = SwiftSimplify.simplify(coordinates, tolerance: MapViewController.lineTolerance)
        } else{
            simpleCoords = coordinates
        }
        
        //add annotation to first and last coords
        if let firstcoord = simpleCoords!.first {
            let firstpin = MKPointAnnotation()
            firstpin.coordinate = firstcoord
            self.mapView?.addAnnotation(firstpin)
        }
        if simpleCoords!.count > 1, let lastcoord = simpleCoords!.last {
            let lastpin = MKPointAnnotation()
            lastpin.coordinate = lastcoord
            self.mapView?.addAnnotation(lastpin)
        }
        
        let polyline = MKPolyline(coordinates: &simpleCoords!, count: coordinates.count)
        self.mapView?.add(polyline)
        setVisibleMapArea(polyline: polyline, edgeInsets: UIEdgeInsetsMake(25.0,25.0,25.0,25.0))
    }
    
    func setVisibleMapArea(polyline: MKPolyline, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: edgeInsets, animated: animated)
    }
    
    // MARK: - MapViewDelegate implementation
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = MapViewController.strokeColor
        renderer.lineWidth = MapViewController.lineWidth
        
        return renderer
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        log.debug("mapview add annotation")
        
        if annotation is MKUserLocation {
            return nil
        } else if annotation is ImageAnnotation {
            guard let imgAnnotation = annotation as? ImageAnnotation else{ return nil }
            let pin = mapView.dequeueReusableAnnotationView(withIdentifier: "imagePin") as? ImagePinAnnotationView ?? ImagePinAnnotationView(annotation: annotation, reuseIdentifier: "imagePin")
            
            pin.pinTintColor = UIColor.darkGray
            pin.canShowCallout = true
            pin.animatesDrop = true
            
            if let imgAsset = imgAnnotation.asset {
                pin.assetId = imageManager.requestImage(for: imgAsset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, data in
                    if pin.assetId == data?[PHImageResultRequestIDKey] as? Int32 {
                        let iv = UIImageView(image: image)
                        pin.leftCalloutAccessoryView = iv
                    }
                })
            }
            return pin
        } else {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "normalAnnotation") ?? MKAnnotationView.init(annotation: annotation, reuseIdentifier: "normalAnnotation")
            
            view.image = MapViewController.pinAnnotationImageView
            
            return view
        }
    }
    
    public func getSnapshot(_ callback: @escaping MKMapSnapshotCompletionHandler) {
        let options = MKMapSnapshotOptions()
        if #available(iOS 11.0, *) {
            options.mapType = MKMapType.mutedStandard
        } else {
            // Fallback on earlier versions
        }
        if let coords = crumbsManager?.currentPath?.getPoints() {
            options.mapRect = getZoomRect(from: coords)
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
    var asset : PHAsset?
}

class ImagePinAnnotationView : MKPinAnnotationView {
    var assetId : Int32?
}
