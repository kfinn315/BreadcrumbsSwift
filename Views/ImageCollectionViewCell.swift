//
//  ImageCollectionViewCell.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/22/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    func configurecell(image: UIImage) {
        imageView.image = image        
    }
}
