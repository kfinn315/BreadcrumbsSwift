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

public class PathDetailViewController : UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var disposeBag = DisposeBag()
    
    public var path : Path?
    var mapManager : MapViewManager?
    // var library : ALAssetsLibrary? = ALAssetsLibrary()
    
    public var albumImg : UIImage?
    public var albumAssets : PhotoCollection?
    
    @IBOutlet weak var ivAlbum: UIImageView!
    @IBOutlet weak var lblAlbum: UILabel!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var cellPhotos: UITableViewCell!
    
    var managedObjectContext : NSManagedObjectContext?
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
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            managedObjectContext = appDelegate.managedObjectContext
        }
        
        self.AlbumAlert = UIAlertController(title: "Photo Album", message: "Would you like to create an album or choose an existing one?", preferredStyle: UIAlertControllerStyle.alert)
        let actionAlbum = UIAlertAction.init(title: "Create an Album", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.createAnAlbum()})
        let actionExisting = UIAlertAction.init(title: "Choose an Existing Album", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in self.showPhotoLibrary()})
        self.AlbumAlert?.addAction(actionAlbum)
        self.AlbumAlert?.addAction(actionExisting)
        self.AlbumAlert?.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    }
    public func createAnAlbum(){
        if let start = path?.startdate, let end = path?.enddate {
            PhotoManager.createTimespanAlbum(name: "\(path?.title ?? "breadcrumb") - \((start as Date).datestring)", start: start as Date, end: end as Date, completionHandler: {(collection, error) in
                if collection != nil {
                    self.path?.albumData = collection
                    
                    DispatchQueue.main.async {
                        self.updateCells()
                    }
                }
                if error != nil {
                    print("error "+error!.localizedDescription)
                }
            })
        }
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        mapManager = MapViewManager(map: mapView)
        btnEdit.rx.tap.subscribe({ _ in
            //start editing mode
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "New Path") as? NewPathViewController {
                vc.path = self.path
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: disposeBag)
        
        mapView.isUserInteractionEnabled = false
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }

        self.updateCells()
    }
    
    
    public func showPhotoLibrary()
    {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "Albums")
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //
        ////        if path?.albumURL == nil {
        ////            //create album
        ////        } else{
        ////            //album = PhotoAlbum(
        ////
        //
        //        //}
        //
        //        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
        //            let myPickerController = UIImagePickerController()
        //            myPickerController.delegate = self;
        //            myPickerController.sourceType = .photoLibrary
        //            self.present(myPickerController, animated: true, completion: nil)
        //        }
    }
    
    private func updateCells(){
        if let mypath = path {
            if let date = mypath.startdate {
                lblDate.text = date.string
            }
            lblTitle.text = mypath.title
            lblDistance.text = "\(mypath.distance)"
            lblLocation.text = mypath.locations
            
            if let albumData = mypath.albumData {
                lblAlbum.text = "Album \(albumData.collection.localizedTitle ?? "unknown")"
                
                if let image = albumData.thumbnail {
                    ivAlbum.image = image
                } else if albumData.asset != nil{
                    PHImageManager.default().requestImage(for: albumData.asset!, resultHandler: { (img, dict) in
                        mypath.albumData?.thumbnail = img
                        self.ivAlbum.image = img
                    })
                } else{
                    self.ivAlbum.image = nil
                }
            } else {
                lblAlbum.text = "Photo Album"
                ivAlbum.image = nil
            }
            
            mapManager?.LoadCrumb(path: path!)
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 5){ //photo album
            if path?.albumData == nil, AlbumAlert != nil {
                present(AlbumAlert!, animated: true, completion: nil)
            } else{
                //show selected photos
                let photovc = storyboard?.instantiateViewController(withIdentifier: "Photos Table") as! PhotosViewController
                photovc.assetCollection = path?.albumData?.collection
                self.navigationController?.pushViewController(photovc, animated: true)
            }
        } else if(indexPath.row == 1) //map
        {
            if path != nil, let vc = storyboard?.instantiateViewController(withIdentifier: "MapVC") as? MapViewController {
                self.navigationController?.pushViewController(vc, animated: true)
                vc.path = path
            }
        }
    }
    
    //:-Mark implementation of UIImagePickerControllerDelegate
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.dismiss(animated: true, completion: nil)
        
        if picker.sourceType == .camera {
            //TODO:- implement camera picker
        } else if picker.sourceType == .photoLibrary {
            if let controllerAsset = info[UIImagePickerControllerPHAsset] as? PHAsset {
                let imageURL = info[UIImagePickerControllerImageURL] as? URL
                
                do{
                    let photoLocation = controllerAsset.location
                    let timestamp = controllerAsset.creationDate
                    
                    let managedObj = NSManagedObject(context: managedObjectContext!)
                    managedObj.setValue("id", forKey: "id")
                    managedObj.setValue(photoLocation?.coordinate.longitude, forKey: "longitude")
                    managedObj.setValue(photoLocation?.coordinate.latitude, forKey: "latitude")
                    managedObj.setValue(timestamp! as NSDate, forKey: "timestamp")
                    managedObj.setValue(path?.id, forKey: "pathID")
                    managedObj.setValue(imageURL, forKey: "url")
                    
                    let photo = Photo(entity: managedObj)
                    try managedObjectContext?.rx.update(photo)
                }catch{
                    print("error "+error.localizedDescription)
                }
            }
        }
    }
}
