//
//  Path.swift
//  BreadcrumbsSwift
//
//  Created by Kevin Finn on 4/26/17.
//  Copyright © 2017 Kevin Finn. All rights reserved.
//

import Foundation
import MapKit
import CloudKit

class PathsType{

   // var UserId:Int;
    var Title:String;
    var Description:String;
    var Points:Array<CLLocation>;
    var RecID:CKRecordID?;
    
    init(UserId:Int,Title:String,Description:String,Points:Array<CLLocation>){
    //    self.UserId = UserId;
        self.Title = Title;
        self.Description = Description
        self.Points = Points;
        
    }
    
    init(record:CKRecord, database:CKDatabase){
       // UserId = Int64(record.objectForKey("UserId"));
       // record.allKeys();
   //     UserId = record["UserId"] as! Int;
        Title = record["Title"] as! String;
        Description = record["Description"] as! String;
        Points = record["Points"] as! Array<CLLocation>;
        RecID = record.recordID;
    }
    
    internal func ToCrumb() -> Crumb{
        let crumb = Crumb();
        
        crumb.Description = self.Description;
        for location in self.Points {
            crumb.Path.append(location);
        }
        crumb.Title = self.Title;
        crumb.RecordId = self.RecID;
    //    crumb.UserId = self.UserId;
        
        return crumb;
    }
}
