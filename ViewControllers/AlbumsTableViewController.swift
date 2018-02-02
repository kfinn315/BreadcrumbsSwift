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
        cell.textLabel?.text = container.collection.localizedTitle

        cell.imageView?.image = container.thumbnail
//
//        if container.asset != nil {
//        cell.tag = Int(manager.requestImage(for: container.asset!,
//                                            targetSize: CGSize(width: 100.0, height: 100.0),
//                                            contentMode: .aspectFill,
//                                            options: nil) { [weak self] (result, _) in
//                                                if let destinationCell = tableView.cellForRow(at: indexPath) {
//                                                    self?.data[indexPath.row].thumbnail = result
//                                                    destinationCell.imageView?.image = result
//                                                    destinationCell.setNeedsLayout()
//                                                }
//        })
//        }
//
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = self.data[indexPath.row]
        _ = CrumbsManager.shared.UpdateCurrentAlbum(collection: album)
        
        self.navigationController?.popViewController(animated: true)
    }

}
