//
//  CloudKitError.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 6/6/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import CloudKit


extension ICloudStatusError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .Unknown:
            return NSLocalizedString("Unknown iCloud Account", comment: "")
        case .NoAccount:
            return NSLocalizedString("No iCloud account is set up", comment: "")
        }
    }
   
}

public enum ICloudStatusError: Error{
    case Unknown
    case NoAccount
    
}
