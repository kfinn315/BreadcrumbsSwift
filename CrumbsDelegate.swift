//
//  CrumbsDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 5/9/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit

protocol CrumbsDelegate: class{
    func CrumbSaved(_ Id: CKRecordID);
    
    func CrumbsLoaded(_ Crumbs: Array<PathsType>);
    
    func CrumbsReset();
    
    func errorUpdatingCrumbs(_ Error: Error);
    
    func errorSavingData(_ Error: Error);
}
