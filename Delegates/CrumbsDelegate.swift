//
//  CrumbsDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/9/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit

@objc protocol CrumbsDelegate: class{
    @objc optional func CrumbSaved(error: Error?);
    
    @objc optional func CrumbsReset();
    
    @objc optional func errorUpdatingCrumbs(_ Error: Error);
    
    @objc optional func errorSavingData(_ Error: Error);
    
    @objc optional func CrumbsUpdated();
}
