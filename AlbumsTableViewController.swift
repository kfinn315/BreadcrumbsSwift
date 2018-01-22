//
//  AlbumsTableViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/18/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift
import RxCocoa
import RxDataSources


public class AlbumsTableViewController : UITableViewController {
    var disposeBag = DisposeBag()
    
    var data : [PhotoCollection] = []
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupPhotos()
    }
    
    private func setupPhotos() {
        self.data = PhotoManager.getCollections()
        self.tableView.reloadData()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return data.count
        }
        
        return 0
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath)
        
        let manager = PHImageManager.default()
        
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        let container = data[indexPath.row]
        let asset = container.asset
        
        cell.textLabel?.text = container.collection.localizedTitle

        if asset != nil {
        cell.tag = Int(manager.requestImage(for: asset!,
                                            targetSize: CGSize(width: 100.0, height: 100.0),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                if let destinationCell = tableView.cellForRow(at: indexPath) {
                                                    destinationCell.imageView?.image = result
                                                    destinationCell.setNeedsLayout()
                                                }
        })
        }
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vcs =  self.navigationController?.viewControllers
        guard vcs != nil else{ return }
        _ = vcs!.popLast()
        if let vc = vcs!.last as? PathDetailViewController {
            var album = data[indexPath.row]
            vc.path?.albumData = album
            if album.thumbnail == nil {
                if let thumbnail = tableView.cellForRow(at: indexPath)?.imageView?.image{
                    album.thumbnail = thumbnail
                }
            }
        }
        
        navigationController?.setViewControllers(vcs!, animated: true)
    }
    //    private func downloadAndSetImage(asset: AssetContainer) {
    //        if asset.thumbnail == nil {
    //            let imageRequestOptions = PHImageRequestOptions()
    //            imageRequestOptions.isNetworkAccessAllowed = false
    //            imageRequestOptions.isSynchronous = true
    //            imageRequestOptions.deliveryMode = .highQualityFormat
    //
    //            PHImageManager.default().requestImage(for: asset.asset.first, targetSize: self.targetImageSize(), contentMode: .AspectFit, options: imageRequestOptions, resultHandler: { (img, info) -> Void in
    //                    asset.thumbnail = img
    //                    self.albumImage.image = asset.thumbnail
    //            })
    //        } else {
    //            albumImage.image = asset.thumbnail
    //        }
    //    }
}
