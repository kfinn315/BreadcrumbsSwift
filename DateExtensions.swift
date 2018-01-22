//
//  DateExtensions.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 1/12/18.
//  Copyright © 2018 Kevin Finn. All rights reserved.
//

import Foundation
import CoreLocation

extension NSDate{
    
    var string: String{
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/YY hh:mm"
        return dateFormatter.string(from: self as Date)
    }

}



extension Date{
    
    var datestring: String{
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "MM/dd/YY"
        return dateFormatter.string(from: self as Date)
    }
    
}
