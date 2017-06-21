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
    private var CurrentCrumb : PathsType?
    
    override func viewDidLoad() {
        super.viewDidLoad()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func awakeFromNib() {
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "navController") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "NavList") {
            self.leftViewController = controller
        }
        super.awakeFromNib()
    }
    
    public func SetMainCrumb(path: PathsType?){
        CurrentCrumb = path;
        if let unwrappedPath = path{
            (((self.mainViewController as! UINavigationController).topViewController) as! MapViewController).LoadCrumb(path: unwrappedPath);
        } else{
            (((self.mainViewController as! UINavigationController).topViewController) as! MapViewController).ClearMap()
        }        
    }
    
    public func GetMainCrumb() -> PathsType?{
        return CurrentCrumb;
    }
}

