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
            log.debug("trying again to create the album")
            self.createAlbum()
        } else {
            log.error("should really prompt the user to let them know it's failed")
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
                log.error("error \(error?.localizedDescription ?? "")")
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
}
