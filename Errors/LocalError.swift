//
//  HttpError.swift
//  mobile
//
//  Created by Kevin Finn on 10/18/17.
//  Copyright © 2017 Hypur. All rights reserved.
//

import Foundation

enum LocalError: Error {
    case failed(message: String)
}

extension LocalError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failed(message: let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}

