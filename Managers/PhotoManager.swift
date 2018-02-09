//
//  PhotoManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/19/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import Photos
import RxSwift
import RxCocoa

public class PhotoCollection {
    var opts = PHFetchOptions()

    init(_ collection: PHAssetCollection) {
        self._collection = collection
        
        if #available(iOS 9.0, *) {
            opts.fetchLimit = 1
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let assets = PHAsset.fetchAssets(in: self.collection, options: self.opts)

            //get first image to use as collection thumbnail
            if let thumbnailAsset = assets.firstObject {
                PHImageManager.default().requestImageThumbnail(for: thumbnailAsset, resultHandler: { [weak self] (img, _) in
                    self?.thumbnail = img
                })
            } else {
                print("unable to fetch asset of PhotoCollection")
            }
        }
    }
    private var _collection : PHAssetCollection
    var collection : PHAssetCollection {
        return _collection
    }
    var thumbnail : UIImage?
    var title : String {
        return collection.localizedTitle ?? ""
    }
    var localid : String {
        return collection.localIdentifier
    }
}

class PhotoManager {
    static func getPhotoCollection(from localId : String) -> PhotoCollection? {
        if let coll = getAssetCollection(from: localId) {
            return PhotoCollection(coll)
        }
        
        return nil
    }
    static func getAssetCollection(from localId : String) -> PHAssetCollection? {
        let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localId], options: nil)
        return result.firstObject
    }
    static func getImages(_ localid: String) -> (String?,[PHAsset]?)? {
        let photoalbum = getPhotoCollection(from: localid)
        
        if let album = photoalbum {
            return (album.title, getImages(album.collection))
        }
        return nil
    }
    static func getImages(_ collection: PHAssetCollection) -> [PHAsset] {
        var assets : [PHAsset] = []
        let result = PHAsset.fetchAssets(in: collection, options: nil)
        result.enumerateObjects({ (asset, _, _) in
            if asset.location != nil {
                assets.append(asset)
            }
        })
        
        return assets
    }
    
    //do on worker thread
    static func getCollections() -> [PhotoCollection] {
        var data : [PhotoCollection] = []
        let fetchOptions = PHFetchOptions()
        let topLevelfetchOptions = PHFetchOptions()

        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)

        topLevelUserCollections.enumerateObjects({ (asset, _, _) in
            if let a = asset as? PHAssetCollection, a.estimatedAssetCount > 0 {
                let obj = PhotoCollection(a)
                data.append(obj)
            }
        })
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)

        smartAlbums.enumerateObjects({ (asset, _, _) in
            let a = asset as PHAssetCollection
            if a.estimatedAssetCount > 0 {
                let obj = PhotoCollection(a)
                data.append(obj)
            }
        })
        
        data.sort(by: { (date0, date1) -> Bool in
            return date0.collection.endDate ?? Date() <= date1.collection.endDate ?? Date()
        })
        return data
    }
    
    //returns localized id of assetcollection
    static func createTimespanAlbum(name: String, start: Date, end: Date, completionHandler: @escaping (PhotoCollection?, Error?) -> Void) {
        let album = PhotoAlbum(albumname: name)
        album.addPhotosInTimespan(start: start, end: end, completionHandler: completionHandler)
    }
}

extension PHImageManager {
    func requestImageThumbnail(for phasset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable:Any]?) -> Void) {
        self.requestImage(for: phasset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
    }
}
