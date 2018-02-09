//
//  CrumbsDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/9/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit

@objc protocol CrumbsDelegate: class {
    @objc optional func crumbSaved(error: Error?)
    
    @objc optional func crumbsReset()
    
    @objc optional func errorUpdatingCrumbs(_ error: Error)
    
    @objc optional func errorSavingData(_ error: Error)
    
    @objc optional func crumbsUpdated()
}
