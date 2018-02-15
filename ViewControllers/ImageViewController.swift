//
//  ImageViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 2/5/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit
import Photos

public class ImageViewController : UIViewController {
    private var assetSize: CGSize!

    public weak var asset : PHAsset?
    
    @IBOutlet weak var imageView: UIImageView!
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assetSize = self.imageView.frame.size
        
        if asset != nil {
            PHImageManager.default().requestImage(for: asset!, targetSize: self.assetSize, contentMode: .aspectFit, options: nil, resultHandler: { [weak self] (result, _) in
                    if result != nil {
                        self?.imageView.image = result!
                    }
            })
        }
    }
}
