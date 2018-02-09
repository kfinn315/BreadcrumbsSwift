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
        case .unknown:
            return NSLocalizedString("Unknown iCloud Account", comment: "")
        case .noAccount:
            return NSLocalizedString("No iCloud account is set up", comment: "")
        }
    }
   
}

public enum ICloudStatusError: Error {
    case unknown
    case noAccount
}
