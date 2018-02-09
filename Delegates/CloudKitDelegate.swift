//
//  CrumbsDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/29/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit

@objc
protocol CloudKitDelegate: class {
    
    @objc optional func crumbSaved(_ recordid: CKRecordID)
    
    //func CrumbsLoaded(_ Crumbs: Array<PathsType>);
    
    @objc optional func crumbsReset() throws
    
    @objc optional func crumbDeleted(_ recordID: CKRecordID)
    
    @objc optional func errorUpdatingCrumbs(_ error: Error)
    
    @objc optional func errorSavingData(_ error: Error)
    
    @objc optional func crumbsUpdated()
}
