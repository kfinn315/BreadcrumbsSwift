//
//  PhotoAlbumManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/18/18.
//

import Foundation
import Photos

class PhotoAlbum: NSObject {
    var albumName : String
    var assetCollection: PHAssetCollection!
    var id : String?
    
    init(albumname: String) {
        self.albumName = albumname
        super.init()
        
        setup()
    }
    
    func setup() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in status
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            // ideally this ensures the creation of the photo album even if authorization wasn't prompted till after init was done
            print("trying again to create the album")
            self.createAlbum()
        } else {
            print("should really prompt the user to let them know it's failed")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)   // create an asset collection with the album name
        }, completionHandler: { success, error in
            if success {
                self.assetCollection = self.fetchAssetCollectionForAlbum()
                self.id = self.assetCollection.localIdentifier
            } else {
                print("error \(error?.localizedDescription ?? "")")
            }
        })
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        return nil
    }
    
    func addPhotosInTimespan(start: Date, end: Date, completionHandler: @escaping (PhotoCollection?, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            guard self.assetCollection != nil else {
                print("error asset collection is nil")
                return
            }
            
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection!)
            let opts = PHFetchOptions()
            opts.predicate = NSPredicate(format: "creationDate >= %@ AND creationDate <= %@", start as NSDate, end as NSDate)
            let fetchresult = PHAsset.fetchAssets(with: .image, options: opts)
            albumChangeRequest?.addAssets(fetchresult)
        }, completionHandler: { (_, error) in
            if error !=  nil {
                print("error "+error!.localizedDescription)
            }
            
            var photoCollection : PhotoCollection? = nil
            if self.assetCollection != nil {
                photoCollection = PhotoCollection(self.assetCollection!)
            }
            completionHandler(photoCollection, error)
        })
    }
 
//    func save(image: UIImage) {
//        if assetCollection == nil {
//            return                          // if there was an error upstream, skip the save
//        }
//
//        PHPhotoLibrary.shared().performChanges({
//            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
//            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
//            let enumeration: NSArray = [assetPlaceHolder!]
//            albumChangeRequest!.addAssets(enumeration)
//
//        }, completionHandler: nil)
//    }
}
