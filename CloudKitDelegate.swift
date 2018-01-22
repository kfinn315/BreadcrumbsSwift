//
//  CrumbsDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/29/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitDelegate: class {
    
    func CrumbSaved(_ Id: CKRecordID);
    
    //func CrumbsLoaded(_ Crumbs: Array<PathsType>);
    
    func CrumbsReset() throws;
    
    func CrumbDeleted(_ RecordID: CKRecordID);
    
    func errorUpdatingCrumbs(_ Error: Error);
    
    func errorSavingData(_ Error: Error);
    
    func CrumbsUpdated(_ Crumbs: Array<PathsType>);
}
