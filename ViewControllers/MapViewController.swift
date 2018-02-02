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
import RxSwift
import RxCocoa

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var disposeBag = DisposeBag()
    
    private weak var path : Path?
    var mapManager : MapViewManager?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapManager = MapViewManager(map: mapView);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CrumbsManager.shared.currentPath.asObservable().subscribe(onNext: { [weak self] path in
                self?.path = path
            if path != nil {
                self?.mapManager?.LoadCrumb(path: path!)
            }
        }).disposed(by: disposeBag)
        
        CrumbsManager.shared.currentPhotoCollection.asObservable().subscribe(onNext: {[weak self] collection in
            if let collectionImages = collection {
                self?.AddImagePoints(collectionImages)
            }
        }).disposed(by: disposeBag)

        //        if path != nil {
//            mapManager?.LoadCrumb(path: path!)
//            if path!.albumData != nil {
//                let assets = PhotoManager.getImages(path!.albumData!.collection)
//                AddImagePoints(assets)
//            }
//        }
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
        
        AddPathLine(path);
        mapManager?.ZoomToFit();
        
        //CrumbsManager.shared.currentPath = path;
    }
    
    func ClearMap(){
        mapView.removeAnnotations(mapView.annotations);
        mapView.removeOverlays(mapView.overlays)
    }
    
    func AddPathLine(_ path: PathsType){
        var locations = Array<CLLocation>();
        
        if let points = path.GetPoints() {
            for point in points {
                locations.append(point);
                let annotation = MKPointAnnotation();
                annotation.coordinate = point.coordinate;
                annotation.title = String(point.coordinate.latitude)+","+String(point.coordinate.longitude);
                self.mapView.addAnnotation(annotation);
            }
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
        
        //self.mapView.add(points)
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

