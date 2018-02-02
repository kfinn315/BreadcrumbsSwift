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

    public var Record:CKRecord?;
    
    init(){
    }
    
    init(record:CKRecord, database:CKDatabase){
       // UserId = Int64(record.objectForKey("UserId"));
       // record.allKeys();
   //     UserId = record["UserId"] as! Int;
//        Title = record["Title"] as! String;
//        Description = record["Description"] as! String;
//        Points = record["Points"] as! Array<CLLocation>;
        Record = record;
    }
    
     func GetUserID() -> Int?{
        return Record!["UserId"] as! Int?;
    }
    
    func GetUserName() -> String?{
        return Record!["UserName"] as! String?;
    }
    
    func GetPoints() -> Array<CLLocation>?{
        return Record!["Points"] as! Array<CLLocation>?;
    }
    
    func GetTitle() -> String?{
        return Record!["Title"] as! String?;
    }
    
    func GetDescription() -> String?{
        return Record!["Description"] as! String?;
    }
    internal func ToCrumb() -> Path{
        let crumb = Path();
        
        if let descr = Record?["Description"] as? String{
            crumb.notes = descr
        }
        
//        if let points = Record?["Points"] as? Array<Point> {
////            var pts = points //broken
//        }
        
        crumb.title = Record?["Title"] as? String ?? ""
        //crumb.RecordId = Record?["UserId"] as? CKRecordID;
        
        return crumb;
    }
    
    func SetDescription(Desc: String){
        Record?["Description"] = Desc as CKRecordValue;
    }
    
    func SetTitle(Title: String){
        Record?["Title"] = Title as CKRecordValue;
    }
    
    func SetPoints(Points: Array<CLLocation>){
        Record?["Points"] = Points as CKRecordValue;
    }
    
    func SetUserID(UserID: Int){
        Record?["UserID"] = UserID as CKRecordValue;
    }
    
    func SetUserName(UserName: String) {
        Record?["UserName"] = UserName as CKRecordValue;
    }
    
    func GetIsShared() -> Bool{
        let isShared = Record?["IsShared"] as! Int32?
        if let isSharedUnwrapped = isShared{
            return isSharedUnwrapped==1;
        }
        
        return false;
    }
    
}
