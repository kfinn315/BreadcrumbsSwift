//
//  MulticastDelegate.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/29/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation

class DelegateMulticast <T> {
    
    fileprivate var delegates = [T]()
    
    func addDelegate(_ delegate: T) {
        delegates.append(delegate)
    }
    
    func invokeDelegates(_ invocation: (T) -> ()) {
        for delegate in delegates {
            invocation(delegate)
        }
    }
}
