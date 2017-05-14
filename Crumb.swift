//
//  Crumb.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/20/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import CloudKit

class Crumb : NSObject{
    var Path = Array<CLLocation>();
    var Title = String();
    var Description = String();
    var Date = String();
    var Duration = Float();
    var Distance = Float();
    var UserId = Int();
    var RecordId : CKRecordID?;
}
