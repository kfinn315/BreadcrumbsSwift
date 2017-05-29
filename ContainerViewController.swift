//
//  ContainerViewController.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/24/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import UIKit

class ContainerViewController: SlideMenuController{
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "Main") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavList") {
            self.leftViewController = controller
        }
        super.awakeFromNib()
    }
    
    public func SetMainCrumb(path: PathsType){
        (self.mainViewController as! MapViewController).LoadCrumb(path: path);
    }
}

