//
//  PhotoManager.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/19/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import Photos

public struct PhotoCollection {
    var opts = PHFetchOptions()

    init(_ collection: PHAssetCollection) {
        self.collection = collection
        
        if #available(iOS 9.0, *) {
            opts.fetchLimit = 1
        }
        
        let ass = PHAsset.fetchAssets(in: collection, options: opts)
        if let phasset = ass.firstObject {
            self.asset = phasset
            self.thumbnail = nil
        }
    }
    
    var collection : PHAssetCollection
    var asset : PHAsset?
    var thumbnail : UIImage?
    var title : String {
        return collection.localizedTitle ?? ""
    }
    var id : String {
        return collection.localIdentifier
    }
}

class PhotoManager{
    static func getPhotoCollection(from localId : String) -> PhotoCollection?{
        if let coll = getAssetCollection(from: localId) {
            return PhotoCollection(coll)
        }
        
        return nil
    }
    static func getAssetCollection(from localId : String) -> PHAssetCollection? {
        let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localId], options: nil)
        return result.firstObject
    }
    static func getImages(_ collection: PHAssetCollection) -> [PHAsset]{
        var assets : [PHAsset] = []
        let result = PHAsset.fetchAssets(in: collection, options: nil)
        result.enumerateObjects({ (asset, start, finish) in
            if asset.location != nil{
                assets.append(asset)
            }
        })
        
        return assets;
    }
    
    //do on worker thread
    static func getCollections() -> [PhotoCollection]{
        var data : [PhotoCollection] = []
        let fetchOptions = PHFetchOptions()
        let topLevelfetchOptions = PHFetchOptions()

        let topLevelUserCollections = PHCollectionList.fetchTopLevelUserCollections(with: topLevelfetchOptions)

        topLevelUserCollections.enumerateObjects({ (asset, index, stop) in
            if let a = asset as? PHAssetCollection, a.estimatedAssetCount > 0 {
                let obj = PhotoCollection(a)
                data.append(obj)
            }
        })
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)

        smartAlbums.enumerateObjects({ (asset, index, stop) in
            let a = asset as PHAssetCollection
            if a.estimatedAssetCount > 0 {
                let obj = PhotoCollection(a)
                data.append(obj)
            }
        })
        
        data.sort(by: { (a, b) -> Bool in
            return a.collection.endDate ?? Date() <= b.collection.endDate ?? Date()
        })
        return data
    }
    
    //returns localized id of assetcollection
    static func createTimespanAlbum(name: String, start: Date, end: Date, completionHandler: @escaping (PhotoCollection?, Error?)->Void) {
        let album = PhotoAlbum(albumname: name)
        album.addPhotosInTimespan(start: start, end: end, completionHandler: completionHandler)
    }
}

extension PHImageManager {
    func requestImage(for phasset: PHAsset, resultHandler: @escaping (UIImage?, [AnyHashable:Any]?)->Void){
        self.requestImage(for: phasset, targetSize: CGSize(width: 50, height: 50), contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
    }
}
