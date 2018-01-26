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
    
    @objc optional func CrumbSaved(_ Id: CKRecordID);
    
    //func CrumbsLoaded(_ Crumbs: Array<PathsType>);
    
    @objc optional func CrumbsReset() throws;
    
    @objc optional func CrumbDeleted(_ RecordID: CKRecordID);
    
    @objc optional func errorUpdatingCrumbs(_ Error: Error);
    
    @objc optional func errorSavingData(_ Error: Error);
    
    @objc optional func CrumbsUpdated()
}
