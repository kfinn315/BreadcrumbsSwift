//
//  PathViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/11/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import MapKit
import UIKit
import RxSwift
import RxCocoa
import Photos
import CoreData
import RxCoreData

public class PathDetailViewController : UITableViewController {
    var disposeBag = DisposeBag()
    
    var crumbsManager : CrumbsManager?
    private weak var path : Path?
    var mapManager : MapViewManager?
    
    public var albumImg : UIImage?
    public var albumAssets : PhotoCollection?
    
    @IBOutlet weak var ivAlbum: UIImageView!
    @IBOutlet weak var lblAlbum: UILabel!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var cellPhotos: UITableViewCell!
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    
    var AlbumAlert : UIAlertController?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup(){
        crumbsManager = CrumbsManager.shared
        
        self.AlbumAlert = UIAlertController(title: "Photo Album", message: "Would you like to create an album or choose an existing one?", preferredStyle: UIAlertControllerStyle.alert)
        let actionAlbum = UIAlertAction.init(title: "Create an Album", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.createAnAlbum()})
        let actionExisting = UIAlertAction.init(title: "Choose an Existing Album", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.showPhotoLibrary()})
        self.AlbumAlert?.addAction(actionAlbum)
        self.AlbumAlert?.addAction(actionExisting)
        self.AlbumAlert?.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mapManager = MapViewManager(map: mapView)
        btnEdit.rx.tap.subscribe({ _ in
            self.editPath()
        }).disposed(by: disposeBag)
        
        mapView.isUserInteractionEnabled = false
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        path = crumbsManager?.currentPath
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        self.updateCells()
    }
    
    public func createAnAlbum(){
        if let start = path?.startdate, let end = path?.enddate {
                PhotoManager.createTimespanAlbum(name: "\(self.path?.title ?? "breadcrumb") - \((start as Date).datestring)", start: start as Date, end: end as Date, completionHandler: {
                    [weak self] (collection, error) in
                    if collection != nil {
                        _ = self?.crumbsManager?.UpdateCurrentAlbum(collection: collection!)
                        
                        DispatchQueue.main.async {
                            self?.updateCells()
                        }
                    }
                    if error != nil {
                        print("error "+error!.localizedDescription)
                    }
                })
            }
    }
    
    public func showPhotoLibrary()
    {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Albums")
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func updateCells(){
        if let mypath = path {
            if let date = mypath.startdate {
                lblDate.text = date.string
            }
            self.title = mypath.title
            lblDistance.text = "distance: \(mypath.distance) m"
            lblSteps.text = "steps: \(mypath.stepcount ?? 0)"
            lblLocation.text = mypath.locations
            lblNotes.text = mypath.notes
            
            if let albumData = mypath.albumData {
                lblAlbum.text = "Album \(albumData.collection.localizedTitle ?? "unknown")"
                
                self.ivAlbum.image = albumData.thumbnail              
            } else {
                lblAlbum.text = "Photo Album"
                ivAlbum.image = nil
            }
            
            mapManager?.LoadCrumb(path: mypath)
        }
    }
    
    @objc func editPath(){
        self.navigationController?.pushViewController(EditPathViewController(), animated: true)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 3){ //photo album
            if path?.albumData == nil, AlbumAlert != nil {
                present(AlbumAlert!, animated: true, completion: nil)
            } else{
                //show selected photos
                let photovc = storyboard?.instantiateViewController(withIdentifier: "Photos Table") as! PhotosViewController
                photovc.assetCollection = path?.albumData?.collection
                self.navigationController?.pushViewController(photovc, animated: true)
            }
        } else if(indexPath.row == 0) //map
        {
            if path != nil, let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as? MapViewController {
                self.navigationController?.pushViewController(vc, animated: true)
                vc.path = path
            }
        }
    }
}
