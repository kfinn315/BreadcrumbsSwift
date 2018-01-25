//
//  MapViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/10/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import UIKit
import MapKit
import CloudKit
import Photos

class MapViewController: UIViewController, CloudKitDelegate {
    @IBOutlet weak var buttonShare: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    
    public var path : Path?
    var mapManager : MapViewManager?;
    //var container : ContainerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapManager = MapViewManager(map: mapView);
        
        //        self.container = (self.parent?.parent as! ContainerViewController);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if path != nil {
            mapManager?.LoadCrumb(path: path!)
            if path!.albumData != nil {
                let assets = PhotoManager.getImages(path!.albumData!.collection)
                AddImagePoints(assets)
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //load main crumb and display
    public func LoadCrumb(path: PathsType){
        ClearMap();
        self.navigationController?.navigationItem.title = path.GetTitle()
        //setShared(path.GetIsShared());
        
        AddLine(crumb: path);
        mapManager?.ZoomToFit();
        
        //CrumbsManager.shared.currentPath = path;
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
//    func AddImageCollection(_ album: PHAssetCollection){
//            var assets : [PHAsset] = []
//            let result = PHAsset.fetchAssets(in: album, options: nil)
//            result.enumerateObjects({ (asset, start, finish) in
//                if asset.location != nil{
//                    assets.append(asset)
//                }
//            })
//
//            AddImagePoints(assets)
//    }
    func AddImagePoints(_ assets: [PHAsset]){
        
        for asset in assets {
            if let loc = asset.location {
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize.init(width: 50, height: 50), contentMode: .aspectFit, options: nil, resultHandler: { (img, dict) in
                    let annotation = ImageAnnotation()
                    annotation.coordinate = loc.coordinate
                    annotation.title = asset.creationDate?.datestring ?? ""
                    annotation.image = img
                    self.mapView.addAnnotation(annotation)
                })
            }
        }
        
        //self.mapView.add(points)
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
        let imageview = UIImageView(image: image)
        pin.leftCalloutAccessoryView = imageview
        return pin
    }
}

